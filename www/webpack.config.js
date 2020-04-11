const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = {
    mode: 'production',
    entry: './src/index.js',
    output: {
        filename: 'webfuse-example.js',
        library: 'webfuse',
        libraryTarget: 'umd',
        path: path.resolve(__dirname, './dist')
    },
    plugins: [
        new HtmlWebpackPlugin({
            title: "Webfuse Example",
            filename: "index.html",
            template: "./src/index.html"
        }),
        new CopyWebpackPlugin([
            { from: './src/style', to: 'style' }
        ])
    ],
    resolve: {
        alias: {
            webfuse: "webfuse/src/index.js"
        }
    }
};
