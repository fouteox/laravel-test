#!/bin/sh
set -e

if [ "$1" = 'frankenphp' ]; then
	# Install the project the first time PHP is started
	# After the installation, the following block can be deleted
	if [ ! -f composer.json ]; then
		rm -Rf tmp/
		composer create-project "laravel/laravel $LARAVEL_VERSION" tmp --stability="$STABILITY" --prefer-dist --no-progress --no-interaction

		cd tmp
		cp -Rp . ..
		cd -
		rm -Rf tmp/
	fi

	if [ -z "$(ls -A 'vendor/' 2>/dev/null)" ]; then
    		composer install --prefer-dist --no-progress --no-interaction
    		php artisan key:generate
    fi

	setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX storage bootstrap/cache
	setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX storage bootstrap/cache
fi

exec docker-php-entrypoint "$@"
