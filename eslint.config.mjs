import prettier from "eslint-plugin-prettier";
import html from "eslint-plugin-html";
import globals from "globals";

export default [
  {
    ignores: [
      "dist/",
      "build/",
      "elm-stuff/",
      ".cache/",
      ".firebase/",
      ".parcel-cache/",
    ],
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

    rules: {
      "prettier/prettier": "error",

      "no-underscore-dangle": [
        "error",
        {
          allowAfterThis: true,
        },
      ],
    },
    files: ["src/**", "templates/**", "site/**", "examples/**", "cypress/**"],
  },
  {
    name: "Test files",
    files: ["**/*.test.html"],
    rules: {
      "no-unused-expressions": "off",
    },
    plugins: {
      prettier,
      html,
    },
  },
];
