<?php

use Illuminate\Support\Str;

$db_url = env('DATABASE_URL', env('DB_URL'));
$host = env('DB_HOST', '127.0.0.1');

if ($db_url && strpos($db_url, '-pooler') !== false) {
    $db_url = str_replace('-pooler', '', $db_url);
}

if ($host && strpos($host, '-pooler') !== false) {
    $host = str_replace('-pooler', '', $host);
}

return [

    'default' => env('DB_CONNECTION', 'pgsql'),

    'connections' => [

        'sqlite' => [
            'driver' => 'sqlite',
            'url' => env('DB_URL'),
            'database' => database_path('database.sqlite'),
            'prefix' => '',
            'foreign_key_constraints' => env('DB_FOREIGN_KEYS', true),
        ],

        'pgsql' => [
            'driver' => 'pgsql',
            'url' => $db_url,
            'host' => $host,
            'port' => env('DB_PORT', '5432'),
            'database' => env('DB_DATABASE', 'forge'),
            'username' => env('DB_USERNAME', 'forge'),
            'password' => env('DB_PASSWORD', ''),
            'charset' => 'utf8',
            'prefix' => '',
            'prefix_indexes' => true,
            'search_path' => 'public',
            'sslmode' => 'require',
            'options' => [
                PDO::ATTR_EMULATE_PREPARES => false, // Set to false for Postgres
            ],
        ],

    ],

    'migrations' => 'migrations',

    'redis' => [
        'client' => env('REDIS_CLIENT', 'phpredis'),
        'options' => [
            'cluster' => env('REDIS_CLUSTER', 'redis'),
            'prefix' => Str::slug(env('APP_NAME', 'laravel'), '_').'_database_',
        ],
        'default' => [
            'url' => env('REDIS_URL'),
            'host' => env('DB_HOST', '127.0.0.1'),
            'username' => env('REDIS_USERNAME'),
            'password' => env('REDIS_PASSWORD'),
            'port' => env('REDIS_PORT', '6379'),
            'database' => env('REDIS_DB', '0'),
        ],
    ],

];
