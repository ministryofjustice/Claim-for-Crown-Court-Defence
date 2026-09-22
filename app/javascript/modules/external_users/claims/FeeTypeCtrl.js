moj.Modules.FeeTypeCtrl = {
  activate: function () {
    return $('#claim_form_step').val() === 'miscellaneous_fees'
  },

  init: function () {
    if (this.activate()) {
      this.bindEvents()
    }
  },

  bindEvents: function () {
    this.miscFeeTypesSelectChange()
    this.miscFeeTypesRadioChange()
    this.pageLoad()
  },

  getFeeTypeSelectUniqueCode: function (context) {
    return $(context).closest('.fx-fee-group').find('option:selected').data('unique-code')
  },

  getFeeTypeRadioUniqueCode: function (context) {
    return $(context).closest('.fx-fee-group').find(':checked').data('unique-code')
  },

  // needs to be usable by cocoon:after-insert so can bind to one or many elements
  miscFeeTypesSelectChange: function ($el) {
    const self = this
    const $els = $el || $('.fx-fee-group')

    if ($('.fx-unused-materials-warning').exists()) {
      $els.on('change', function () {
        self.showHideUnusedMaterialWarning(this, self.getFeeTypeSelectUniqueCode(this))
      })
    }
    if ($('.fee-quantity').exists()) {
      $els.on('change', function () {
        self.readOnlyQuantity(this, self.getFeeTypeSelectUniqueCode(this))
      })
    }
  },

  // needs to be usable by cocoon:after-insert so can bind to one or many elements
  miscFeeTypesRadioChange: function ($el) {
    const self = this
    const $els = $el || $('.fx-fee-group')

    if ($('.fx-unused-materials-warning').exists()) {
      $els.on('change', function () {
        self.showHideUnusedMaterialWarning(this, self.getFeeTypeRadioUniqueCode(this))
      })
    }
  },

  showHideUnusedMaterialWarning: function (context, uniqueCode) {
    const show = (uniqueCode === 'MIUMO')
    const $warning = $(context).closest('.fx-fee-group').find('.fx-unused-materials-warning')
    show ? $warning.removeClass('js-hidden') : $warning.addClass('js-hidden')
  },

  readOnlyQuantity: function (context, uniqueCode) {
    const readOnly = ['MIUMU', 'MISTE', 'MIAPF'].includes(uniqueCode)
    const defaultQuantity = 1
    const $quantity = $(context).closest('.fx-fee-group').find('input.fee-quantity')
    if (readOnly) {
      if (`${$quantity.val()}` !== `${defaultQuantity}`) {
        $quantity.val(defaultQuantity)
        $quantity.trigger('keyup')
      }
      $quantity.attr('readonly', true)
    } else {
      $quantity.removeAttr('readonly')
    }
  },

  pageLoad: function () {
    const self = this

    $(function () {
      $('.js-fee-type:visible').each(function () {
        self.showHideUnusedMaterialWarning(this, self.getFeeTypeSelectUniqueCode(this))
        self.readOnlyQuantity(this, self.getFeeTypeSelectUniqueCode(this))
      })

      $('.fee-type input[type=radio]:checked').each(function () {
        self.showHideUnusedMaterialWarning(this, self.getFeeTypeRadioUniqueCode(this))
      })
    })
  }
}
