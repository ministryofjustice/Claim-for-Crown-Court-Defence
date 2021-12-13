(function () {
  'use strict'

  function requireAll (context) {
    context.keys().forEach(context)
  }

  requireAll(require.context('../../../spec/javascripts/helpers/', true, /\.js/))
  requireAll(require.context('../../../spec/javascripts/', true, /[sS]pec\.js/))
})()
