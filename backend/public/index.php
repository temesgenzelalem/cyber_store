<?php
echo "PHP STARTING<br>";

try {
    echo "REQUIRE AUTOLOAD<br>";
    require __DIR__.'/../vendor/autoload.php';
    echo "REQUIRE APP<br>";
    $app = require_once __DIR__.'/../bootstrap/app.php';
    echo "APP CREATED<br>";

    $kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
    echo "KERNEL CREATED<br>";

    $response = $kernel->handle(
        $request = Illuminate\Http\Request::capture()
    );
    echo "REQUEST HANDLED<br>";

    $response->send();
    $kernel->terminate($request, $response);
} catch (\Throwable $e) {
    echo "<h1>CRASH</h1>";
    echo "Error: " . $e->getMessage();
}
