<?php
// Carregar variáveis do ambiente
$dbHost = getenv('DB_HOST');
$dbName = getenv('DB_NAME');
$dbUser = getenv('DB_USER');
$dbPass = getenv('DB_PASS');

// Teste de conexão com o banco
$dbStatus = 'Não testado';
try {
    $pdo = new PDO("mysql:host=$dbHost;dbname=$dbName;charset=utf8mb4", $dbUser, $dbPass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $dbStatus = 'Conexão OK';
} catch (Exception $e) {
    $dbStatus = 'Erro: ' . $e->getMessage();
}

// Teste de escrita no storage
$storagePath = __DIR__ . '/../storage/teste.txt';
$writeStatus = 'Não testado';
try {
    file_put_contents($storagePath, "Teste de escrita: " . date('Y-m-d H:i:s'));
    $writeStatus = 'OK';
} catch (Exception $e) {
    $writeStatus = 'Erro: ' . $e->getMessage();
}
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Ambiente de Teste - gestao1.sieca.net</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f4f4f4;
            padding: 40px;
        }
        .box {
            background: #fff;
            padding: 25px;
            border-radius: 8px;
            max-width: 600px;
            margin: auto;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 { color: #333; }
        .ok { color: green; font-weight: bold; }
        .erro { color: red; font-weight: bold; }
        .info { margin-bottom: 10px; }
    </style>
</head>
<body>
<div class="box">
    <h1>Ambiente de Teste</h1>

    <div class="info">
        <strong>Servidor:</strong> gestao1.sieca.net
    </div>

    <div class="info">
        <strong>PHP:</strong> <?= phpversion() ?>
    </div>

    <div class="info">
        <strong>Banco de Dados:</strong>
        <span class="<?= strpos($dbStatus, 'OK') !== false ? 'ok' : 'erro' ?>">
            <?= $dbStatus ?>
        </span>
    </div>

    <div class="info">
        <strong>Teste de Escrita (storage/):</strong>
        <span class="<?= $writeStatus === 'OK' ? 'ok' : 'erro' ?>">
            <?= $writeStatus ?>
        </span>
    </div>

    <hr>

    <p>Se tudo estiver verde, o ambiente está funcionando corretamente.</p>
</div>
</body>
</html>
