// TODO: Remove if not needed:
// from AGFS fixed fees AND does not look like
// required for AGFS misc fees.
moj.Modules.FeeFieldsDisplay = {
  init: function () {
    this.addFeeChangeEvent($('.fx-fee-group'))
  },
  addFeeChangeEvent: function (el) {
    const self = this
    const $el = $(el)

    $el.find('select.js-fee-type').each(function () {
      const el = $(this).closest('.fx-fee-group')
      self.showHideFeeFields(el)
    })

    $el.find('.js-typeahead').on('typeahead:change', function () {
      const el = $(this).closest('.fx-fee-group')
      self.showHideFeeFields(el)
    })
  },
  showHideFeeFields: function (el) {
    const currentElement = $(el)
    const caseNumbersInput = currentElement.find('input.fx-fee-case-numbers')

    if (caseNumbersInput.exists()) {
      const showCaseNumbers = currentElement.find('option:selected').data('case-numbers')
      const caseNumbersWrapper = caseNumbersInput.closest('.case_numbers_wrapper')

      if (showCaseNumbers) {
        caseNumbersWrapper.show()
      } else {
        caseNumbersInput.val('')
        caseNumbersWrapper.hide()
      }
    }
  }
}
