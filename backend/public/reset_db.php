<?php
header('Content-Type: text/plain');
echo "DB RESET START\n";

require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

try {
    $db = Illuminate\Support\Facades\DB::connection();
    echo "Connecting to: " . $db->getDatabaseName() . "\n";

    echo "Executing DROP SCHEMA\n";
    $db->statement('DROP SCHEMA public CASCADE');
    echo "Executing CREATE SCHEMA\n";
    $db->statement('CREATE SCHEMA public');
    echo "Executing GRANT\n";
    $db->statement('GRANT ALL ON SCHEMA public TO public');

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
