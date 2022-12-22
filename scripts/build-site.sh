#!/usr/bin/env bash

./scripts/clean.sh
./scripts/build.sh

mkdir -p ./dist/site/

cp ./dist/*.js ./dist/site/

soupault --build-dir dist/site
