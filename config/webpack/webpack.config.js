const path = require('path')
const mode = process.env.NODE_ENV === 'development' ? 'development' : 'production'
const webpack = require('webpack')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const FixStyleOnlyEntriesPlugin = require('webpack-fix-style-only-entries')

module.exports = {
  // mode: 'development',
  // devtool: 'source-map',
  mode,
  entry: {
    application: ['./app/webpack/packs/application.js']
  },
  output: {
    filename: '[name].js',
    assetModuleFilename: '[name][ext]',
    path: path.resolve(__dirname, '..', '..', 'app/assets/builds'),
    clean: true
  },
  optimization: {
    moduleIds: 'hashed'
  },
  module: {
    rules: [
      {
        test: /\.(js)$/,
        exclude: /node_modules/,
        use: ['babel-loader']
      },
      {
        test: /\.scss$/i,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          'sass-loader'
        ]
      },
      {
        test: /\.(png)$/i,
        type: 'asset/resource'
      },
      {
        test: /\.(woff|woff2|ttf)$/i,
        type: 'asset/resource'
      },
      {
        test: /\.(svg|ico)$/,
        loader: 'file-loader',
        options: {
          name: '[name].[ext]'
        }
      }
    ]
  },
  resolve: {
    // Add additional file types
    extensions: ['.js', '.scss', '.css']
  },
  plugins: [
    // new webpack.optimize.LimitChunkCountPlugin({
    //   maxChunks: 1
    // }),
    new FixStyleOnlyEntriesPlugin(),
    new MiniCssExtractPlugin(),
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
      'window.jQuery': 'jquery',
      'global.jQuery': 'jquery',
      accessibleAutocomplete: 'accessible-autocomplete',
      Dropzone: 'dropzone/dist/dropzone.js',
      Stickyfill: 'stickyfilljs'
    })
  ]
}
