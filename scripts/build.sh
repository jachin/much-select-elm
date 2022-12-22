#!/usr/bin/env bash

# To learn more about what all is going on here and why checkout the wiki
# https://github.com/DripEmail/much-select-elm/wiki/How-the-Build-Works

# Ensure the build directory is there
mkdir -p ./build

# Ensure the dist directory is there
mkdir -p ./dist

# Do a production build of the filter worker. This will result in a file
# which lives here: build/gen/filter-worker.js
#./scripts/build-worker.sh
./scripts/build-minified-worker.sh

# Read in the generated file into a variable.
FILTER_WORKER_JS=$(<build/gen/filter-worker.js)

# Here we have our little JavaScript template. This code should
#  mirror what we have else where. It would be great if this could
#  live in 1 place.
read -d '' tpl << EOF
const getMuchSelectTemplate = (styleTag) => {
  const templateTag = document.createElement("template");
  templateTag.innerHTML = \`
    <div>
      \${styleTag}
      <slot name="select-input"></slot>
      <div id="mount-node"></div>
      <script id="filter-worker" type="javascript/worker">
        %s
      </script>
    </div>
  \`;
  return templateTag;
};

export default getMuchSelectTemplate;
EOF


# Generate the muchSelectTemplate es6 module.
printf "$tpl" "$FILTER_WORKER_JS" > ./dist/much-select-template.js

# Clean up. We do not need the filter worker (by it self) any more
#  since all it contents have been put in /build/gen/much-select-template.js
#  so lets clean up after ourselves.
rm build/gen/filter-worker.js

# We are all done with the gen directory, so lets clean that up too
rmdir ./build/gen

# Compile the Main elm file into JavaScript and optimize it because this
# build is for production. So also put the out put in the dist directory.
npx elm-esm make ./src/Main.elm --output=./dist/elm-main.js --optimize

# There are more JavaScript modules (files) the production build need, let's copy those over
#  to the build directory
cp ./src/much-select.js ./dist/much-select.js
cp ./src/ascii-fold.js ./dist/ascii-fold.js
cp ./src/diacritics.js ./dist/diacritics.js

# We want a version of much select with debugger turned on, because sometimes
# that is helpful. It should not be used in production but we should ship it in the
# dist folder.
npx elm-esm make src/Main.elm --output=dist/elm-main-debug.js --debug
cp ./src/much-select.js ./dist/much-select-debug.js

# This condition is because we need format sed differently if we're on macOS for in the Github actions environment.
if [[ -v GITHUB_RUN_ID ]]; then
  sed -i -e 's/elm-main\./elm-main-debug\.js/g' ./dist/much-select-debug.js
else
  sed -i '' -e 's/elm-main\./elm-main-debug\.js/g' ./dist/much-select-debug.js
fi
