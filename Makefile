.PHONY: test build

# User editable vars
PLUGIN_NAME ?= class-drop-cookie.php
WORDPRESS_VERSION ?= latest
WORDPRESS_DB_NAME ?= wordpress
WORDPRESS_DB_USER ?= wordpress
WORDPRESS_DB_PASSWORD ?= password
WORDPRESS_DB_HOST ?= localhost
WORDPRESS_DIR ?= /tmp/wordpress
WORDPRESS_TEST_HARNESS_DIR ?= /tmp/wordpress-test-harness
WORKSPACE_DIR ?= /workspace
BIN_DIR ?= /usr/local/bin
BUILD_DIR ?= build
SVN_DIR ?= svn

# Shortcuts
DOCKER_COMPOSE := @docker-compose -f docker/docker-compose.yml
DOCKER_EXEC := exec -u www-data wordpress /bin/bash -c
CD_TO_WORKSPACE := cd $(WORKSPACE_DIR);

# Commands
all: docker_clean docker_start docker_all

shell:
	$(DOCKER_COMPOSE) $(DOCKER_EXEC) "/bin/bash"

docker_setup_wp_core:
	$(DOCKER_COMPOSE) $(DOCKER_EXEC) "make setup_wp_core"

docker_start:
	$(DOCKER_COMPOSE) up -d --build

docker_stop:
	$(DOCKER_COMPOSE) stop

docker_clean:
	$(DOCKER_COMPOSE) stop | true
	$(DOCKER_COMPOSE) rm -vf

docker_all:
	$(DOCKER_COMPOSE) $(DOCKER_EXEC) "$(CD_TO_WORKSPACE) make install lint test"

docker_test:
	$(DOCKER_COMPOSE) $(DOCKER_EXEC) "$(CD_TO_WORKSPACE) make lint test"

docker_phpcbf:
	$(DOCKER_COMPOSE) $(DOCKER_EXEC) "$(CD_TO_WORKSPACE) make phpcbf"

install: composer_self_update composer_install install_wp_cli install_wp install_wp_test_harness

composer_self_update:
	composer self-update

composer_install:
	composer install -o --prefer-dist --no-interaction

install_wp_cli:
	curl -o $(BIN_DIR)/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x $(BIN_DIR)/wp

install_wp: setup_wp_core setup_wp_config setup_wp_db

setup_wp_core:
	wp core download --force --path="$(WORDPRESS_DIR)"

setup_wp_config:
	wp config create --path="$(WORDPRESS_DIR)" --force \
		--dbname="${WORDPRESS_DB_NAME}" \
		--dbuser="${WORDPRESS_DB_USER}" \
		--dbpass="${WORDPRESS_DB_PASSWORD}" \
		--dbhost="${WORDPRESS_DB_HOST}"

setup_wp_db:
	wp db reset --path="$(WORDPRESS_DIR)" --yes
	wp core install --path="$(WORDPRESS_DIR)" --skip-email \
		--url="http://localhost" \
		--title="Test" \
		--admin_user="test" \
		--admin_password="test" \
		--admin_email="test@test.com"

install_wp_test_harness:
	install_test_harness

lint:
	./vendor/bin/phpcs --standard=./test/phpcs.xml .

phpcbf:
	./vendor/bin/phpcbf --standard=./test/phpcs.xml .

test:
	./vendor/bin/phpunit -c ./test/phpunit.xml --testsuite=unit-tests
