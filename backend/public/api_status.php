<?php
header('Content-Type: application/json');

try {
    require __DIR__.'/../vendor/autoload.php';
    $app = require_once __DIR__.'/../bootstrap/app.php';

    $kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

    echo json_encode([
        'status' => 'ok',
        'message' => 'Laravel Bootstrapped Perfectly',
        'php' => phpversion(),
        'env' => env('APP_ENV'),
        'debug' => env('APP_DEBUG')
    ]);
} catch (\Throwable $e) {
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ]);
}
