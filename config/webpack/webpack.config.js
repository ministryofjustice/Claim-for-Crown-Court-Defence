const path = require('path')
const mode = process.env.NODE_ENV === 'development' ? 'development' : 'production'
const webpack = require('webpack')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const RemoveEmptyScriptsPlugin = require('webpack-remove-empty-scripts')
const TerserPlugin = require('terser-webpack-plugin')

module.exports = {
  mode,
  entry: {
    application: [
      './app/webpack/packs/application.js',
      './app/webpack/stylesheets/application.scss'
    ]
  },
  output: {
    filename: '[name].js',
    assetModuleFilename: '[name][ext]',
    path: path.resolve(__dirname, '..', '..', 'app/assets/builds'),
    clean: {
      keep: /.keep/
    }
  },
  optimization: {
    moduleIds: 'deterministic',
    minimize: true,
    minimizer: [
      new TerserPlugin({
        parallel: true,
        terserOptions: {
          ecma: 5,
          parse: {},
          compress: {},
          mangle: true,
          module: false,
          output: null,
          format: null,
          toplevel: false,
          nameCache: null,
          ie8: false,
          keep_classnames: undefined,
          keep_fnames: false,
          safari10: false
        }
      })
    ]
  },
  module: {
    rules: [
      {
        test: /\.(js)$/,
        exclude: /node_modules/,
        use: ['babel-loader']
      },
      {
        test: /\.(?:sa|sc|c)ss$/i,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          'sass-loader'
        ]
      },
      {
        test: /\.(png|svg)$/i,
        type: 'asset/resource'
      },
      {
        test: /\.(woff|woff2|ttf)$/i,
        type: 'asset/resource'
      },
      {
        test: /\.(ico)$/,
        loader: 'file-loader',
        options: {
          name: '[name].[ext]'
        }
      },
      {
        test: require.resolve('accessible-autocomplete'),
        loader: 'expose-loader',
        options: {
          exposes: 'accessibleAutocomplete'
        }
      }
    ]
  },
  resolve: {
    extensions: ['.js', '.scss', '.css']
  },
  plugins: [
    new MiniCssExtractPlugin(),
    new RemoveEmptyScriptsPlugin(),
    new webpack.ProvidePlugin({
      $: require.resolve('jquery'),
      jQuery: require.resolve('jquery'),
      jquery: require.resolve('jquery'),
      Dropzone: require.resolve('dropzone/dist/dropzone.js'),
      Stickyfill: require.resolve('stickyfilljs'),
      MOJFrontend: require.resolve('@ministryofjustice/frontend/moj/all.js')
    })
  ]
}
