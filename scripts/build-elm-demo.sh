#!/usr/bin/env bash

# Ensure the build directory is there
mkdir -p ./build

npx elm-esm make ./src/Demo.elm --output=./build/elm-demo.js --debug

# Add some new lines to the compiled elm (JavaScript) so we can put the 2 files
# together it easy to see where 1 starts and the other ends.
printf "\n\n" >> ./build/elm-demo.js

cat ./src/elm-demo.js >> ./build/elm-demo.js
