#!/usr/bin/env bash

# Ensure the build/gen directory is there.
mkdir -p ./build/gen

# Build the filter worker and put it in the build/gen file.
npx elm make src/FilterWorker.elm --output build/gen/filter-worker-elm-dev.js

# Add some new lines to the compiled elm (JavaScript) so we can put the 2 files
# together it easy to see where 1 starts and the other ends.
printf "\n\n" >> build/gen/filter-worker-elm-dev.js

# Concatenate the compiled Elm (JavaScript) and the JavaScript
# for initiating the Elm app and handing the ports. Make sure
# the compiled Elm comes first.
cat build/gen/filter-worker-elm-dev.js src/filter-worker.js > build/gen/filter-worker-dev.js

# We don't need "just" the compiled elm (JavaScript) for the filter worker any more so
#  lets clean up after our selves.
rm build/gen/filter-worker-elm-dev.js
