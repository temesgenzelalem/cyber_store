FROM php:8.2-apache

# Install high-speed PHP extensions
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions pdo_pgsql bcmath zip

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Update Apache document root correctly
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Set working directory
WORKDIR /var/www/html

# Copy project files
COPY . .

# Ensure standard Laravel directories exist and have CORRECT permissions
RUN mkdir -p storage/framework/cache/data \
             storage/framework/sessions \
             storage/framework/views \
             storage/logs \
             bootstrap/cache && \
    touch storage/logs/laravel.log && \
    chown -R www-data:www-data /var/www/html/storage \
                               /var/www/html/bootstrap/cache \
                               /var/www/html/storage/logs/laravel.log && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_NO_AUDIT=1

# Install dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader --no-security-blocking

EXPOSE 80

# Professional Start Script
RUN echo '#!/bin/sh\n\
# Set permissions again at runtime to be 100% sure\n\
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache\n\
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache\n\
\n\
php artisan migrate --force\n\
php artisan config:cache\n\
php artisan route:cache\n\
apache2-foreground' > /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh

CMD ["/usr/local/bin/start.sh"]
