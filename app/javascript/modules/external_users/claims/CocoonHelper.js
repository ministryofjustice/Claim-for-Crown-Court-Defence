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
    let counter = 0

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

    $elem.on('cocoon:before-insert', function (_e, insertedItem) {
      insertedItem.find('.govuk-form-group').each(function () {
        const newId = $(this).find(':input').attr('id').concat('-', counter++)
        $(this).find(':input').attr('id', newId)
        $(this).find('label').attr('for', newId)
      })
    })
  }
}
