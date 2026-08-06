#!/bin/bash
set -e

# Only fix permissions if the Laravel app has already been initialized
if [ -f "/var/www/html/artisan" ]; then
    # Ensure runtime directories exist
    mkdir -p /var/www/html/storage/framework/{views,sessions,cache} /var/www/html/bootstrap/cache
    
    # Fix ownership and permissions
    chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache
    chmod -R g+s /var/www/html/storage /var/www/html/bootstrap/cache
fi

# Execute the container's CMD (e.g., apachectl or composer)
exec "$@"