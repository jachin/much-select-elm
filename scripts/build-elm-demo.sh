#!/usr/bin/env bash

# This a script for building the Elm demo App. Since we want much-select to
# work well as part of a larger Elm app, it's important that we're able
# to test the featuers of much-select in Elm's virtual DOM's.

# Ensure the build directory is there
mkdir -p ./build

npx elm-esm make ./src/Demo.elm --output=./build/elm-demo.js --debug

# Add some new lines to the compiled elm (JavaScript) so we can put the 2 files
# together it easy to see where 1 starts and the other ends.
printf "\n\n" >> ./build/elm-demo.js

# Put together the compiled Elm and JavaScript to start up the app.
cat ./src/elm-demo.js >> ./build/elm-demo.js
