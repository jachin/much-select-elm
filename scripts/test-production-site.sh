#!/usr/bin/env bash

./scripts/clean.sh
./scripts/build.sh

soupault

cp ./dist/*.js ./build/

python3 -m http.server 1234 --directory ./build/
