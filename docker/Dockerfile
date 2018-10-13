FROM wordpress:php7.2

# Install xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug

# Install apt dependencies
RUN apt-get update && apt-get install -qq -y --fix-missing --no-install-recommends \
    build-essential \
    mysql-client \
    subversion \
    unzip \
    zip \
    ;

# Install composer
RUN curl https://getcomposer.org/installer -s -o composer-setup.php \
    && php composer-setup.php --quiet --install-dir=/usr/local/bin/ --filename=composer \
    && rm composer-setup.php \
    ;

# Copy test harness installer
COPY docker/bin/install_test_harness.sh /usr/bin/install_test_harness

# Setup permissions
RUN chown www-data:www-data \
    /usr/local/bin \
    /var/www \
    ;
