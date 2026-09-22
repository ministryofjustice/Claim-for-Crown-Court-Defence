moj.Modules.InterimFeeFieldsDisplay = {
  activate: function () {
    return $('#claim_form_step').val() === 'interim_fees'
  },
  init: function () {
    const self = this

    if (this.activate()) {
      moj.Modules.CaseTypeCtrl.initAutocomplete()
      this.addInterimFeeChangeEvent()
      $('#interim-fee').find('select.js-interim-fee-type').each(function () {
        self.showHideInterimFeeFields(this)
      })
      this.bindEvents()
    }
  },
  bindEvents: function () {
    $('#disbursements').on('cocoon:after-insert', function (e, element) {
      const elId = $(element).find('.fx-autocomplete-wrapper select').attr('id')
      moj.Modules.AutocompleteWrapper.Autocomplete(elId)
    })
  },
  addInterimFeeChangeEvent: function () {
    const self = this

    $('#interim-fee').on('change', 'select.js-interim-fee-type', function () {
      self.showHideInterimFeeFields(this)
      $(self.el).trigger('recalculate')
    })
  },

  showHideInterimFeeFields: function (elem) {
    const elements = $(elem).find('option:selected').data()

    if (elements) {
      $.each(elements, function (name, val) {
        if (val) {
          $('.js-interim-' + name).show().removeClass('js-hidden')
        } else {
          $('.js-interim-' + name).hide().addClass('js-hidden').find('input, select, textarea').each(function (i, e) {
            $(this).val('').prop('checked', false)
          })
        }
      })
    }
  }
}
