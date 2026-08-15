FROM php:8.2-apache

# Install high-speed PHP extensions (Keep it minimal for speed and stability)
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions pdo_pgsql zip bcmath gd

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# CRITICAL: Allow .htaccess to work and change DocumentRoot
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Set working directory
WORKDIR /var/www/html

# Copy project files
COPY . .

# Ensure standard Laravel directories exist and have CORRECT permissions
# We use 777 for storage temporarily to bypass any Render-specific permission issues
RUN mkdir -p storage/framework/cache/data \
             storage/framework/sessions \
             storage/framework/views \
             storage/logs \
             bootstrap/cache && \
    chmod -R 777 storage bootstrap/cache && \
    chown -R www-data:www-data /var/www/html

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

# Install dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader --no-security-blocking

EXPOSE 80

# Professional Start Script
RUN echo '#!/bin/sh\n\
# Force permissions at runtime\n\
chmod -R 777 /var/www/html/storage /var/www/html/bootstrap/cache\n\
\n\
php artisan migrate --force || echo "Migration skipped"\n\
php artisan config:clear\n\
php artisan route:clear\n\
\n\
apache2-foreground' > /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh

CMD ["/usr/local/bin/start.sh"]
