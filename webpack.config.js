const { resolve } = require("path");
const webpack = require("webpack");

const publicFolder = resolve("./public");

module.exports = (env) => {
  const webpackLoader = {
    loader: "elm-webpack-loader",
    options: {
      debug: !env.production,
      optimize: env.production,
      cwd: __dirname,
    },
  };

  return {
    mode: env.production ? "production" : "development",
    target: "web",
    entry: env.production ? "./src/much-selector.js" : "./src/index.js",
    devServer: {
      publicPath: "/",
      contentBase: publicFolder,
      port: 8000,
    },
    output: {
      publicPath: "/",
      path: publicFolder,
      filename: "bundle.js",
      library: "muchSelector",
      libraryTarget: "umd",
    },
    module: {
      rules: [
        {
          enforce: "pre",
          test: /\.(js|tsx?)$/,
          exclude: /node_modules/,
          loader: "eslint-loader",
          options: {
            configFile: ".eslintrc.json",
          },
        },
        {
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: env.production
            ? [webpackLoader]
            : [{ loader: "elm-hot-webpack-loader" }, webpackLoader],
        },
      ],
    },
    plugins: [new webpack.NoEmitOnErrorsPlugin()],
  };
};
