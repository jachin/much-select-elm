#!/usr/bin/env bash
npx elm-esm make src/Main.elm --output=dist/elm-main.js --optimize
cp ./src/*.js ./dist/
sed -i '' -e 's/Main\.elm/elm-main\.js/g' dist/much-select.js
