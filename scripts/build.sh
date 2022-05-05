#!/usr/bin/env bash

# This looks odd, what's going on here?
# https://github.com/DripEmail/much-select-elm/wiki/How-the-Build-Works

./scripts/build-worker.py

npx elm-esm make src/Main.elm --output=dist/elm-main.js --optimize

cp ./src/*.js ./dist/
cp ./src/gen/*.js ./dist/gen/

# This condition is because we need format sed differently if we're on macOS for in the Github actions environment.
if [[ -v GITHUB_RUN_ID ]]; then
  sed -i -e 's/Main\.elm/elm-main\.js/g' ./dist/much-select.js
else
  sed -i '' -e 's/Main\.elm/elm-main\.js/g' ./dist/much-select.js
fi
npx elm-esm make src/Main.elm --output=dist/elm-main-debug.js --debug
cp ./src/much-select.js ./dist/much-select-debug.js
# This condition is because we need format sed differently if we're on macOS for in the Github actions environment.
if [[ -v GITHUB_RUN_ID ]]; then
  sed -i -e 's/Main\.elm/elm-main-debug\.js/g' ./dist/much-select-debug.js
else
  sed -i '' -e 's/Main\.elm/elm-main-debug\.js/g' ./dist/much-select-debug.js
fi
