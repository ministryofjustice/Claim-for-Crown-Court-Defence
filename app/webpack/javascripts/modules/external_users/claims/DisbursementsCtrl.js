moj.Modules.DisbursementsCtrl = {
  els: {
    fxAutocomplete: '.fx-autocomplete'
  },
  activate: function () {
    return $('#claim_form_step').val() === 'disbursements'
  },
  initAutocomplete: function () {
    const arr = $(this.els.fxAutocomplete)

    $(this.els.fxAutocomplete).is(function (idx, el) {
      moj.Helpers.Autocomplete.new('#' + el.id, {
        showAllValues: true,
        autoselect: false
      })
    })
  },
  init: function () {
    const self = this
    if (this.activate()) {
      // init the auto complete
      this.initAutocomplete()
      // bind general page events
      this.bindEvents()
    }
  },
  bindEvents: function () {
    const self = this

    $('#disbursements').on('cocoon:after-insert', function (e, element) {
      const elId = $(element).find('.fx-autocomplete').attr('id')
      moj.Helpers.Autocomplete.new('#' + elId, {
        showAllValues: true,
        autoselect: false
      })
    })
  }
}
