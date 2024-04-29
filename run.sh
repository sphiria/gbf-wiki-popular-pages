#!/usr/bin/env bash
set -Eeuo pipefail

# export CLOUDFLARE_TOKEN="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
# export CLOUDFLARE_ZONE_ID="bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
# export WIKI_BOT_USERNAME="aaaaaaaaaa@ddddddd/eeeeeeeeeeeeeeeeeeeeee"
# export WIKI_BOT_PASSWORD="ffffffffffffffffffffffffffffffff"

echo "===> Obtaining top pages from Cloudflare..."
PAGES="$(./01-fetch-top-pages.js)"
echo "$PAGES"
echo

echo "===> Pushing to gbf.wiki..."
./02-write-to-wiki.sh "$PAGES"
