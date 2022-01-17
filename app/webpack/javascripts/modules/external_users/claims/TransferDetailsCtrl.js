moj.Modules.TransferDetailsCtrl = {
  els: {
    fxAutocomplete: '.fx-autocomplete'
  },
  activate: function () {
    return $('#claim_form_step').val() === 'transfer_fee_details'
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
      $.subscribe('/onConfirm/' + $(this.els.fxAutocomplete).attr('id') + '/', function () {
        moj.Modules.TransferDetailFieldsDisplay.callCaseConclusionController()
      })
    }
  }
}
