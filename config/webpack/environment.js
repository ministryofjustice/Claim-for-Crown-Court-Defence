const { environment } = require('@rails/webpacker')
const webpack = require('webpack')
const path = require('path')
// const ConcatPlugin = require('webpack-concat-plugin')
const glob = require('glob')
const getDirectories = function (src) {
  return glob.sync(src + '/**/*.js')
}
const modules = getDirectories('./app/webpack/javascripts/modules')
const plugins = getDirectories('./app/webpack/javascripts/plugins')
const localFiles = modules.concat(plugins)
localFiles.push('./app/webpack/javascripts/application.js')
const localVendors = getDirectories('./app/webpack/javascripts/vendor')

const vendorFiles = [
  'jquery',
  'jquery-ujs',
  'jquery.iframe-transport',
  'dropzone',
  'stickyfilljs',
  'jquery-accessible-accordion-aria',
  'jsrender',
  'jquery-highlight',
  'jquery-throttle-debounce',
  'accessible-autocomplete',
  'datatables.net/js/jquery.dataTables.min.js',
  'datatables.net-buttons/js/dataTables.buttons.min.js',
  'datatables.net-fixedheader/js/dataTables.fixedHeader.min.js',
  'datatables.net-select/js/dataTables.select.min.js',
  'jquery-datatables-checkboxes/js/dataTables.checkboxes.min.js'
]

const concatFiles = vendorFiles.concat(localVendors, localFiles)
// environment.plugins.append('ConcatPlugin', new ConcatPlugin({
//   uglify: true,
//   sourceMap: true,
//   outputPath: 'js',
//   fileName: 'application.bundle.js',
//   filesToConcat: vendorFiles.concat(applicationFiles)
// }))

environment.config.merge({
  entry: {
    app: localFiles,
    vendor: vendorFiles.concat(localVendors)
  },
  output: {
    filename: 'js/[name].bundle.js',
    libraryTarget: 'umd',
    globalObject: 'this'
  },
  plugins: [
    new webpack.ProvidePlugin({
      moj: './app/webpack/javascripts/vendor/moj.js',
      $: 'jquery',
      jQuery: 'jquery'
    })
  ],
  optimization: {
    minimize: true,
    splitChunks: {
      chunks: 'all'
    }
  },
  resolve: {
    alias: {
      moj: path.resolve(__dirname, './app/webpack/javascripts/vendor/moj.js')
    }
  }
})

// console.log('WOOOHHOOO \n', getDirectories('./app/webpack/javascripts'))
console.log('localFiles \n', localFiles)
console.log('localVendors \n', localVendors)
console.log('concatFiles \n', concatFiles)
module.exports = environment
