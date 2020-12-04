moj.Modules.CocoonHelper = {
  el: [
    '#basic-fees',
    '#misc-fees',
    '#fixed-fees',
    '#graduated-fees',
    '#disbursements',
    '#interim-fee',
    '#warrant_fee',
    '#transfer-fee'].join(','),

  init: function () {
    this.addCocoonHooks()
  },

  addCocoonHooks: function () {
    const $elem = $(this.el)

    $elem.on('cocoon:after-insert', function (e) {
      const $el = $(e.target)
      $el.siblings('.no-dates').hide()
    })

    $elem.on('cocoon:after-remove', function (e) {
      const $el = $(e.target)
      if ($el.find('.fee-dates').length === 0) {
        $el.siblings('.no-dates').show()
      }

      $el.trigger('recalculate')
    })
  }
}
