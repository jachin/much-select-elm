const { resolve } = require("path");
const webpack = require("webpack");

const { ENV } = process.env;

const publicFolder = resolve("./public");

const isProd = ENV === "production";

const webpackLoader = {
    loader: "elm-webpack-loader",
    options: {
        debug: !isProd,
        optimize: isProd,
        cwd: __dirname,
    },
};

module.exports = {
    mode: isProd ? "production" : "development",
    entry: isProd ? "./src/much-selector.js" : "./src/index.js",
    devServer: {
        publicPath: "/",
        contentBase: publicFolder,
        port: 8000,
        hotOnly: true,
    },
    output: {
        publicPath: "/",
        path: publicFolder,
        filename: "bundle.js",
    },
    module: {
        rules: [
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                use: isProd
                    ? [webpackLoader]
                    : [{ loader: "elm-hot-webpack-loader" }, webpackLoader],
            },
        ],
    },
    plugins: [new webpack.NoEmitOnErrorsPlugin()],
};
