#!/usr/bin/env bash
# Exit on error
set -e

composer install --no-interaction --prefer-dist --optimize-autoloader

# Run migrations (force because it's production)
php artisan migrate --force
