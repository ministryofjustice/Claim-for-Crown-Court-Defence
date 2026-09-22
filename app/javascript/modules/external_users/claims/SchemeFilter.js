moj.Modules.SchemeFilter = {
  init: function () {
    const self = this

    $('.js-claim-scheme-filter')
      .on('change', ':radio', function () {
        window.location = self.pathWithFilter($(this).val())
      })
  },

  // pathname returns the current url location without any query params
  pathWithFilter: function (scheme) {
    const param = scheme !== 'all' ? '?scheme=' + scheme : ''
    const anchor = '#listanchor'
    return window.location.pathname + param + anchor
  }
}
