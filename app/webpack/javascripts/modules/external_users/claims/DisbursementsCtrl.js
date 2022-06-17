moj.Modules.DisbursementsCtrl = {
  els: {
    fxAutocomplete: '.fx-autocomplete'
  },

  activate: function () {
    return $('#claim_form_step').val() === 'disbursements'
  },

  initAutocomplete: function () {
    $(this.els.fxAutocomplete).is(function (idx, el) {
      moj.Helpers.Autocomplete.new('#' + el.id, {
        showAllValues: true,
        autoselect: false
      })
    })
  },

  init: function () {
    if (this.activate()) {
      // init the auto complete
      this.initAutocomplete()
      // bind general page events
      this.bindEvents()
    }
  },

  bindEvents: function () {
    $('#disbursements').on('cocoon:after-insert', function (e, element) {
      const elId = $(element).find('.fx-autocomplete-wrapper select').attr('id')
      moj.Modules.AutocompleteWrapper.Autocomplete(elId)
    })
  }
}
