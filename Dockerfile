FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install system dependencies, Apache, and Ondřej Surý's PHP PPA
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    zip \
    software-properties-common \
    apache2 \
    libapache2-mod-php8.3 \
    && add-apt-repository ppa:ondrej/php -y \
    && apt-get update

# Install PHP 8.3 and standard Laravel extensions
RUN apt-get install -y \
    php8.3-cli \
    php8.3-common \
    php8.3-mysql \
    php8.3-pgsql \
    php8.3-sqlite3 \
    php8.3-bcmath \
    php8.3-curl \
    php8.3-gd \
    php8.3-intl \
    php8.3-mbstring \
    php8.3-opcache \
    php8.3-redis \
    php8.3-xml \
    php8.3-zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Enable Apache mod_rewrite for Laravel routing
RUN a2enmod rewrite ssl

# Copy custom Apache virtual host configuration
COPY ./docker/apache/default.conf /etc/apache2/sites-available/000-default.conf
# Copy custom php.ini configuration for Apache
COPY ./docker/php/php.ini /etc/php/8.3/apache2/conf.d/99-custom.ini
# Copy custom php.ini for CLI (so Artisan commands also use these settings)
COPY ./docker/php/php.ini /etc/php/8.3/cli/conf.d/99-custom.ini

# Set working directory to Apache root
WORKDIR /var/www/html

# Copy application files from host ./src to container
COPY ./src /var/www/html

# Make sure script is executable
COPY ./docker/scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["entrypoint.sh"]
CMD ["apachectl", "-D", "FOREGROUND"]