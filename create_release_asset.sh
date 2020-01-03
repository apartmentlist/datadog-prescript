#!/usr/bin/env bash

VERSION="$1"

if [[ -z $VERSION ]]; then
  echo "** YOU NEED TO PASS VERSION STRING **"
  exit 1
fi

TAR_FILE=$VERSION.tar

tar cfv $TAR_FILE \
  --exclude=".git*" \
  --exclude="test" \
  --exclude=".DS_Store" \
  --exclude="*.tar" \
  --exclude="*.tar.gz" \
  --exclude="create_release_asset.sh" \
  .

gzip $TAR_FILE
