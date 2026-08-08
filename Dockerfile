# syntax=docker/dockerfile:1
FROM ubuntu:24.04 AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# 1. OPTIMIZATION: Use BuildKit apt cache mounts to speed up system dependency installations
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    unzip \
    zip \
    software-properties-common \
    apache2 \
    libapache2-mod-php8.3 \
    && add-apt-repository ppa:ondrej/php -y

# 2. OPTIMIZATION: Cache PHP installation packages. 
# Keeping this clean means no residual apt logs are baked into the final layer image.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
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
    php8.3-zip

# Enable Apache modules
RUN a2enmod rewrite ssl

# --- COMPOSER DEPENDENCIES STAGE ---
# 3. OPTIMIZATION: Isolate composer vendor building to run concurrently 
FROM base AS vendor
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /tmp/build
COPY ./src/composer.json ./src/composer.lock ./

# 4. OPTIMIZATION: Persistent Composer cache across builds
RUN --mount=type=cache,target=/root/.composer/cache \
    composer install --no-interaction --no-plugins --no-scripts --prefer-dist --no-dev --optimize-autoloader

# --- FRONTEND ASSETS STAGE ---
FROM node:22-alpine AS frontend
WORKDIR /app
COPY ./src/package.json ./src/package-lock.json ./
RUN npm ci
COPY ./src/resources ./resources
COPY ./src/vite.config.js ./
RUN npm run build

# --- FINAL RUNTIME STAGE ---
FROM base AS runner
WORKDIR /var/www/html

# Copy configurations
COPY ./docker/apache/default.conf /etc/apache2/sites-available/000-default.conf
COPY ./docker/php/php.ini /etc/php/8.3/apache2/conf.d/99-custom.ini
COPY ./docker/php/php.ini /etc/php/8.3/cli/conf.d/99-custom.ini

# Copy source code code directly
COPY ./src /var/www/html

# 5. OPTIMIZATION: Copy pre-cached vendor folder from parallel build stage
COPY --from=vendor /tmp/build/vendor /var/www/html/vendor
COPY --from=frontend /app/public/build /var/www/html/public/build

# Optimize Laravel application configuration inside the build
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer dump-autoload --no-dev --classmap-authoritative

# Ensure proper storage permissions for Apache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Setup entrypoint script
COPY ./docker/scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["entrypoint.sh"]
CMD ["apachectl", "-D", "FOREGROUND"]
