const path = require('path');

const HtmlWebPackPlugin = require('html-webpack-plugin');
const { TypedCssModulesPlugin } = require('typed-css-modules-webpack-plugin');

const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const MiniCssExtractPluginConfig = new MiniCssExtractPlugin({
    filename: 'smartplaylist.2.5.2.4862.css',
    chunkFilename: '[local].css',
});

const htmlWebpackPlugin = new HtmlWebPackPlugin({
    template: './index.html',
    filename: './index.html',
});

const outDir = path.join(__dirname, './dist');

module.exports = {
    mode: 'development',
    entry: ['./src/index'],

    devServer: {
        contentBase: outDir,
        hot: true,
        historyApiFallback: true,
    },

    resolve: {
        extensions: ['.ts', '.tsx', '.js', '.css'],
        alias: {
            '~': path.resolve(__dirname, './src'),
        },
    },

    output: {
        path: outDir,
        filename: 'smartplaylist.2.5.2.4862.js',
        library: {
            type: 'amd',
            export: 'default',
        },
    },

    plugins: [
        MiniCssExtractPluginConfig,
        htmlWebpackPlugin,
        new TypedCssModulesPlugin({
            globPattern: 'src/**/*.css',
        }),
    ],

    module: {
        rules: [
            {
                test: /\.css$/,
                use: [
                    MiniCssExtractPlugin.loader,
                    {
                        loader: 'css-loader',
                        options: {
                            modules: {
                                localIdentName: '[name]__[local]',
                            },
                            importLoaders: 1,
                            sourceMap: true,
                        },
                    },
                ],
            },
            {
                test: /\.ts(x?)$/,
                exclude: /node_modules/,
                use: [
                    {
                        loader: 'ts-loader',
                    },
                ],
            },
        ],
    },
};
