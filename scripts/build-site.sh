#!/usr/bin/env bash

# Build the sandbox/demo site for production.

# Clean up all the old assets just to make sure there's no old garbage
# in the dist or build directories.
./scripts/clean.sh

# Do a production build of much-select.
./scripts/build.sh

# Ensure the directory for the site is set.
mkdir -p ./dist/site/

# Copy the production javascript assets to the site.
cp ./dist/*.js ./dist/site/

# Generate all the HTML and copy the styles and images.
# Soupault takes care of all this.
soupault --build-dir dist/site
