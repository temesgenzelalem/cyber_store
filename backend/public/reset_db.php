<?php
echo "DB RESET START\n";

$url = parse_url(getenv('DATABASE_URL') ?: getenv('DB_URL'));

$host = $url['host'];
$user = $url['user'];
$pass = $url['pass'];
$db = ltrim($url['path'], '/');

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$db", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "DROPPING SCHEMA public\n";
    $pdo->exec("DROP SCHEMA public CASCADE");
    echo "CREATING SCHEMA public\n";
    $pdo->exec("CREATE SCHEMA public");
    echo "GRANTING ALL ON SCHEMA public\n";
    $pdo->exec("GRANT ALL ON SCHEMA public TO public");

    echo "SUCCESS\n";
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
