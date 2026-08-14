<?php

try {
    require __DIR__.'/../vendor/autoload.php';
    $app = require_once __DIR__.'/../bootstrap/app.php';

    echo "<h1>LARAVEL BOOTSTRAPPED SUCCESSFULLY</h1>";
    exit;

} catch (\Throwable $e) {
    echo "<h1>APPLICATION CRASH</h1>";
    echo "<p>Error: " . $e->getMessage() . "</p>";
    echo "<p>File: " . $e->getFile() . " on line " . $e->getLine() . "</p>";
    echo "<pre>" . $e->getTraceAsString() . "</pre>";
    exit;
}
