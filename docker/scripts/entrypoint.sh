#!/bin/bash
set -e

# Only fix permissions if the Laravel app has already been initialized
if [ -f "/var/www/html/artisan" ]; then
    # Ensure runtime directories exist
    mkdir -p /var/www/html/storage/framework/{views,sessions,cache} /var/www/html/bootstrap/cache

    if [ "$(id -u)" = "0" ]; then
        # Fix ownership and permissions only as root
        chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
    else
        echo "Skipping ownership fix because container is not running as root"
    fi

    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache || true
    chmod -R g+s /var/www/html/storage /var/www/html/bootstrap/cache || true
fi

# Execute the container's CMD (e.g., apachectl or composer)
exec "$@"