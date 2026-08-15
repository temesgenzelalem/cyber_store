<?php
header('Content-Type: text/plain');
echo "DB RESET START\n";

// Attempt to find DB credentials
$db_url = getenv('DATABASE_URL') ?: getenv('DB_URL');
if (!$db_url) {
    // Try reading from .env file directly as a fallback
    $env_file = __DIR__ . '/../.env';
    if (file_exists($env_file)) {
        $env = parse_ini_file($env_file);
        $host = $env['DB_HOST'] ?? '';
        $user = $env['DB_USERNAME'] ?? '';
        $pass = $env['DB_PASSWORD'] ?? '';
        $db = $env['DB_DATABASE'] ?? '';
        $dsn = "pgsql:host=$host;dbname=$db";
    }
} else {
    $url = parse_url($db_url);
    $host = $url['host'];
    $user = $url['user'];
    $pass = $url['pass'];
    $db = ltrim($url['path'], '/');
    $port = $url['port'] ?? 5432;
    $dsn = "pgsql:host=$host;port=$port;dbname=$db";
}

if (!isset($dsn)) {
    die("ERROR: No database credentials found.\n");
}

try {
    echo "Connecting to $dsn\n";
    $pdo = new PDO($dsn, $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Executing DROP SCHEMA\n";
    $pdo->exec("DROP SCHEMA IF EXISTS public CASCADE");
    echo "Executing CREATE SCHEMA\n";
    $pdo->exec("CREATE SCHEMA public");
    echo "Executing GRANT\n";
    $pdo->exec("GRANT ALL ON SCHEMA public TO public");

    echo "SUCCESS: Database has been wiped and reset.\n";
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
