const { environment } = require('@rails/webpacker')
const ConcatPlugin = require('webpack-concat-plugin')

environment.plugins.append('ConcatPlugin', new ConcatPlugin({
  uglify: true,
  sourceMap: true,
  outputPath: 'js',
  fileName: 'application.bundle.js',
  filesToConcat: [
    'jquery',
    'jquery-migrate',
    'jquery-ujs',
    'jquery.iframe-transport',
    'dropzone',
    'govuk_frontend_toolkit/javascripts/govuk/stick-at-top-when-scrolling.js',
    'govuk_frontend_toolkit/javascripts/govuk/stop-scrolling-at-footer.js',
    'jquery-accessible-accordion-aria',
    'jsrender',
    'jquery-highlight',
    'jquery-throttle-debounce',
    'accessible-autocomplete',
    './app/webpack/javascripts/vendor/**/*',
    'datatables.net/js/jquery.dataTables.min.js',
    'datatables.net-buttons/js/dataTables.buttons.min.js',
    'datatables.net-fixedheader/js/dataTables.fixedHeader.min.js',
    'datatables.net-select/js/dataTables.select.min.js',
    'jquery-datatables-checkboxes/js/dataTables.checkboxes.min.js',
    './app/webpack/javascripts/modules/**/*',
    './app/webpack/javascripts/plugins/**/*',
    './app/webpack/javascripts/application.js'
  ]
}))

environment.config.merge({
  output: {
    filename: 'js/[name]-[hash].js'
  }
})

module.exports = environment
