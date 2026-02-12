# syntax=docker/dockerfile:1

########################################
# Stage 1: composer (build deps cache)
########################################
FROM composer:2 AS build
WORKDIR /app

# copiar apenas metadados do composer (se existirem)
COPY app/composer.json app/composer.lock* ./

# garantir um vendor vazio caso não haja dependências
RUN mkdir -p /app/vendor

# instalar dependências se houver composer.json
RUN if [ -f composer.json ]; then \
      composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader; \
      composer require tecnickcom/tcpdf; \
    fi

########################################
# Stage 2: runtime image (PHP + Apache)
########################################
FROM php:8.2-apache

# --- variáveis de ambiente ---
ENV DEBIAN_FRONTEND=noninteractive
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV LANG=pt_BR.UTF-8
ENV LC_ALL=pt_BR.UTF-8

# --- pacotes e extensões PHP ---
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
       git unzip zip libzip-dev libpng-dev libjpeg-dev libfreetype6-dev \
       libonig-dev libicu-dev libcurl4-openssl-dev pkg-config locales tzdata nano \
  && docker-php-ext-install curl \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j"$(nproc)" pdo pdo_mysql mbstring zip gd intl opcache \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# --- habilitar extensão curl ---
RUN docker-php-ext-enable curl

# --- configurar locale pt_BR.UTF-8 ---
RUN sed -i '/pt_BR.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen pt_BR.UTF-8 \
    && update-locale LANG=pt_BR.UTF-8

# --- copiar composer do stage build ---
COPY --from=build /usr/bin/composer /usr/bin/composer

# --- habilitar módulos Apache úteis ---
RUN a2enmod rewrite headers deflate expires

# --- ajustar DocumentRoot Apache ---
RUN sed -ri -e "s!DocumentRoot /var/www/html!DocumentRoot ${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/sites-available/000-default.conf \
 && printf '<Directory %s>\n    Options Indexes FollowSymLinks\n    AllowOverride All\n    Require all granted\n</Directory>\n' "${APACHE_DOCUMENT_ROOT}" > /etc/apache2/conf-available/app-public.conf \
 && a2enconf app-public

# --- diretório de trabalho ---
WORKDIR /var/www/html

# --- copiar composer metadata and vendor from build stage ---
COPY --from=build /app/composer.json /var/www/html/composer.json
COPY --from=build /app/composer.lock /var/www/html/composer.lock
COPY --from=build /app/vendor /var/www/html/vendor

# --- copiar aplicação ---
COPY app/ ./

# --- ajustar permissões ---
RUN chown -R www-data:www-data /var/www/html \
 && find /var/www/html -type d -exec chmod 0755 {} \; \
 && find /var/www/html -type f -exec chmod 0644 {} \;

# --- expor porta 80 ---
EXPOSE 80

# --- healthcheck ---
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# --- comando padrão (apache) ---
CMD ["apache2-foreground"]
