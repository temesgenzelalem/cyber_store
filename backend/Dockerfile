FROM php:8.2-apache

# Install essentials
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions pdo_pgsql zip bcmath gd

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Change DocumentRoot safely
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/apache2.conf

# Set working directory
WORKDIR /var/www/html

# Copy project files
COPY . .

# Fix permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

# Install dependencies (Force bypass audits)
RUN composer install --no-interaction --prefer-dist --optimize-autoloader --no-security-blocking

EXPOSE 80

# Professional Start Script
RUN echo '#!/bin/sh\n\
# Set permissions again at runtime\n\
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache\n\
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache\n\
\n\
php artisan migrate --force\n\
php artisan config:clear\n\
apache2-foreground' > /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh

CMD ["/usr/local/bin/start.sh"]
