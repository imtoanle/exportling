#!/bin/bash
set -e

echo '--- setting ruby version'
rbenv local 2.3.6

echo '--- bundling'
bundle install -j $(nproc) --without production --quiet

echo '--- setting up db'
bundle exec rake db:create db:schema:load

echo '--- running specs'
REVISION=https://github.com/$BUILDBOX_PROJECT_SLUG/commit/$BUILDBOX_COMMIT
if bundle exec rspec; then
  echo "[Successful] $BUILDBOX_PROJECT_SLUG - Build - $BUILDBOX_BUILD_URL - Commit - $REVISION"
else
  echo "[Failed] Build $BUILDBOX_PROJECT_SLUG - Build - $BUILDBOX_BUILD_URL - Commit - $REVISION"
  exit 1;
fi
