'use strict'

// A standalone `ignores` object stops ESLint reading these files at all.
module.exports = [
  {
    ignores: [
      '**/node_modules/**',
      '**/public/**',
      '**/coverage/**',
      '**/vendor/**',
      '**/app/assets/builds/**',
      '**/app/javascript/vendor/**',
      '**/spec/javascripts/helpers/**',
    ],
  },
  ...require('neostandard')({
    env: ['jasmine', 'jquery'],
    globals: ['GOVUK', 'moj', 'Stickyfill'],
  }),
]
