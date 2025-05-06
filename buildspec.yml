#!/bin/bash

echo "[POSTDEPLOY] Ensuring .env is available..."

cd /var/app/current

# Copy .env.prod to .env if it doesn't exist
if [ ! -f .env ]; then
    echo "[POSTDEPLOY] Copying .env.prod to .env..."
    cp .env.prod .env
else
    echo "[POSTDEPLOY] .env already exists."
fi

# Set correct ownership
sudo chown -R webapp:webapp storage bootstrap/cache

# Ensure log file and required directories exist
mkdir -p storage/logs
touch storage/logs/laravel.log

# Fix permissions for Laravel
chmod -R 777 storage
chmod -R 777 bootstrap/cache
chmod 777 storage/logs/laravel.log

# Install required packages including PHP Zip extension
sudo yum install -y php-zip npm unzip
php composer.phar require league/flysystem-aws-s3-v3 "^3.0" --with-all-dependencies
# Install Node and Composer dependencies
npm install
npm run build

# Generate APP_KEY only if not already set
if grep -q "APP_KEY=" .env && grep -q "^APP_KEY=$" .env; then
    echo "[POSTDEPLOY] Generating new APP_KEY..."
    php artisan key:generate --force
else
    echo "[POSTDEPLOY] APP_KEY already exists, skipping key:generate."
fi

# Laravel optimize and clear commands
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan optimize

# Migrate and seed
php artisan migrate --force
php artisan db:seed --force

echo "[POSTDEPLOY] Deployment tasks completed."
