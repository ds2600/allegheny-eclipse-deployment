#!/bin/bash
#

cd /var/www/allegheny-eclipse/

LAST_VERSION_FILE=".last_version"
VERSION="$1"

VERSIONS=($(git tag | sort -V))

if [ -z "$VERSION" ]; then
    if [ -f "$LAST_VERSION_FILE" ]; then
        LAST_VERSION=$(cat "$LAST_VERSION_FILE")
    else
        LAST_VERSION=""
    fi

    NEXT_VERSION=""
    for i in "${!VERSIONS[@]}"; do
        if [[ "${VERSIONS[$i]}" == "$LAST_VERSION" ]]; then
            NEXT_INDEX=$((i + 1))
            NEXT_VERSION="${VERSIONS[$NEXT_INDEX]}"
            break
        fi
    done

    if [ -z "$NEXT_VERSION" ]; then
        echo "No new version to deploy."
        exit 0
    fi

    VERSION="$NEXT_VERSION"
fi

echo "Deploying version: $VERSION"

git fetch --tags
git checkout "$VERSION" || exit 1
composer install --no-dev --optimize-autoloader
echo "$VERSION" > "$LAST_VERSION_FILE"
echo "Deployment complete for version: $VERSION"

echo "Updating WaybackMachine..."
curl -X POST "https://web.archive.org/save/https://alleghenyeclipse.com" -H "User-Agent: Allegheny Eclipse Deployment Script"
