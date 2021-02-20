#!/usr/bin/env bash

# This looks odd, what's going on here?
# https://github.com/DripEmail/much-select-elm/wiki/How-the-Build-Works

npx elm-esm make src/Main.elm --output=dist/elm-main.js --optimize
cp ./src/*.js ./dist/
sed -i '' -e 's/Main\.elm/elm-main\.js/g' dist/much-select.js
