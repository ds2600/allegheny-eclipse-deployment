#!/bin/bash
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd /var/www/allegheny-eclipse/

LOG_FILE="$SCRIPT_DIR/script.log"
LAST_VERSION_FILE=".last_version"
VERSION="$1"

log() {
    echo [$( date '+%Y-%m-%d %H:%M:%S' )] "$1" >> "$LOG_FILE"
}

log "----- Deployment started -----"


VERSIONS=($(git tag | sort -V))

if [ -z "$VERSION" ]; then
    if [ -f "$LAST_VERSION_FILE" ]; then
        LAST_VERSION=$(cat "$LAST_VERSION_FILE")
        log "Last deployed version: $LAST_VERSION"
    else
        LAST_VERSION=""
        log "No last deployed version found."
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
        log "No new version available to deploy."
        echo "No new version to deploy."
        exit 0
    fi

    VERSION="$NEXT_VERSION"
fi

log "Deploying version: $VERSION"
echo "Deploying version: $VERSION"

git fetch --tags
git checkout "$VERSION" || { log "Failed to checkout version $VERSION"; exit 1; }
composer install --no-dev --optimize-autoloader
log "Composer install completed"

echo "$VERSION" > "$LAST_VERSION_FILE"
log "Updated last deployed version to: $VERSION"

echo "Submitting to Waybck Machine"
curl -X POST "https://web.archive.org/save/https://alleghenyeclipse.com" -H "User-Agent: Allegheny Eclipse Deployment Script"

log "Deployment completed successfully"
echo "Deployment completed successfully"



