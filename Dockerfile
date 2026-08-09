# syntax=docker/dockerfile:1
ARG USER_ID=1000
ARG GROUP_ID=1000

FROM ubuntu:24.04 AS base
ARG USER_ID=1000
ARG GROUP_ID=1000

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
    passwd \
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
RUN a2enmod rewrite ssl && \
    echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf && \
    a2enconf servername

# Create a development user matching the host UID/GID when provided
RUN groupadd -g "${GROUP_ID}" appuser 2>/dev/null || true && \
    if ! id appuser >/dev/null 2>&1; then \
      useradd -o -m -u "${USER_ID}" -g "${GROUP_ID}" -s /bin/bash appuser; \
    fi

# --- COMPOSER DEPENDENCIES STAGE ---
# 3. OPTIMIZATION: Isolate composer vendor building to run concurrently 
FROM base AS vendor
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /tmp/build
COPY ./src/composer.json ./src/composer.lock ./

# 4. OPTIMIZATION: Persistent Composer cache across builds
RUN --mount=type=cache,target=/root/.composer/cache \
    composer install --no-interaction --no-plugins --no-scripts --prefer-dist --no-dev --optimize-autoloader && \
    composer dump-autoload --no-dev --classmap-authoritative --no-scripts

# --- FRONTEND ASSETS STAGE ---
FROM node:22-alpine AS frontend
WORKDIR /app
COPY ./src/package.json ./
RUN corepack enable && corepack pnpm install
COPY ./src/resources ./resources
COPY ./src/vite.config.js ./
RUN corepack pnpm run build

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

# Ensure Laravel cache files are owned by the runtime user
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
    mkdir -p /var/log/apache2 && \
    chown -R www-data:www-data /var/log/apache2

# Setup entrypoint script
COPY ./docker/scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl -f http://localhost/ || exit 1

ENTRYPOINT ["entrypoint.sh"]
CMD ["apachectl", "-D", "FOREGROUND"]
