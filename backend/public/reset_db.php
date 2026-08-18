<?php
header('Content-Type: text/plain');
echo "DB RESET START (v8.1.0)\n";

require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

try {
    $config = config('database.connections.pgsql');
    $dsn = "pgsql:host={$config['host']};port={$config['port']};dbname={$config['database']}";
    echo "Connecting raw PDO to: {$config['host']}\n";

    // Connect without Laravel's wrapper
    $pdo = new PDO($dsn, $config['username'], $config['password']);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Executing DROP SCHEMA public CASCADE\n";
    $pdo->exec("DROP SCHEMA IF EXISTS public CASCADE");
    echo "Executing CREATE SCHEMA public\n";
    $pdo->exec("CREATE SCHEMA public");
    echo "Executing GRANT ALL ON SCHEMA public TO public\n";
    $pdo->exec("GRANT ALL ON SCHEMA public TO public");

    // Close connection
    $pdo = null;
    echo "Raw reset successful. Now running Laravel Migrations...\n";

    // Refresh Laravel's DB connection to be sure
    Illuminate\Support\Facades\DB::purge('pgsql');

    echo "Running Migrations...\n";
    Illuminate\Support\Facades\Artisan::call('migrate', ['--force' => true]);
    echo Illuminate\Support\Facades\Artisan::output();

    echo "Running Seeds...\n";
    Illuminate\Support\Facades\Artisan::call('db:seed', ['--force' => true]);
    echo Illuminate\Support\Facades\Artisan::output();

    echo "SUCCESS: Database has been wiped, migrated, and seeded.\n";
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    echo "TRACE:\n" . $e->getTraceAsString() . "\n";
}
