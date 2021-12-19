process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin
const SpeedMeasurePlugin = require('speed-measure-webpack-plugin')
const smp = new SpeedMeasurePlugin()
environment.plugins.append('BundleAnalyzerPlugin', new BundleAnalyzerPlugin({}))

module.exports = smp.wrap(environment.toWebpackConfig())
