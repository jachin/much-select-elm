import prettier from "eslint-plugin-prettier";
import html from "eslint-plugin-html";
import globals from "globals";

export default [
  {
    ignores: ["dist/*"],
  },
  {
    plugins: {
      prettier,
      html,
    },

    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.mocha,
      },

      ecmaVersion: "latest",
      sourceType: "module",
    },
    ignores: [
      "dist/",
      "build/",
      "elm-stuff/",
      ".cache/",
      ".firebase/",
      ".parcel-cache/",
    ],
    rules: {
      "prettier/prettier": "error",

      "no-underscore-dangle": [
        "error",
        {
          allowAfterThis: true,
        },
      ],
    },
  },
  {
    files: ["**/*.test.html"],

    rules: {
      "no-unused-expressions": "off",
    },
  },
];
