'use strict'

module.exports = require('neostandard')({
  env: ['jasmine', 'jquery'],
  globals: ['GOVUK', 'moj', 'Stickyfill'],
  ignores: [
    '**/node_modules/**',
    '**/public/**',
    '**/coverage/**',
    '**/vendor/**',
    '**/app/assets/builds/**',
    '**/app/webpack/javascripts/vendor/**',
    '**/spec/javascripts/helpers/**',
  ],
})
