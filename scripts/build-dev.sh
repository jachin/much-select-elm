#!/usr/bin/env bash

mkdir -p ./build

./scripts/build-worker-dev.sh

npx elm-esm make src/Main.elm --output=build/elm-main.js --debug

mkdir -p ./build/gen
cp ./src/gen/*.js ./build/gen/
