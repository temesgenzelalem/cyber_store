<?php

require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';

try {
    $kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
    echo "<h1>KERNEL CREATED SUCCESSFULLY</h1>";

    $response = $kernel->handle(
        $request = Illuminate\Http\Request::capture()
    );
    echo "<h1>REQUEST HANDLED SUCCESSFULLY</h1>";

    $response->send();
    $kernel->terminate($request, $response);

} catch (\Throwable $e) {
    echo "<h1>CRASH IN INDEX.PHP</h1>";
    echo "<p>Error: " . $e->getMessage() . "</p>";
    echo "<p>File: " . $e->getFile() . " on line " . $e->getLine() . "</p>";
    echo "<pre>" . $e->getTraceAsString() . "</pre>";
    exit;
}
