#!/usr/bin/env bash

# This a script for building the Elm demo App. Since we want much-select to
# work well as part of a larger Elm app, it's important that we're able
# to test the featuers of much-select in Elm's virtual DOM's.

# Ensure the build directory is there
mkdir -p ./build

npx elm-watch make --debug elm-demo
