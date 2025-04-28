#!/bin/bash
#

cd /opt/allegheny-eclipse/
git fetch origin
git checkout $1
composer install --no-dev --optimize-autoloader


