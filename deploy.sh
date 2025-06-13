#!/bin/bash
#

cd /var/www/allegheny-eclipse/
git pull origin $1 
composer install --no-dev --optimize-autoloader


