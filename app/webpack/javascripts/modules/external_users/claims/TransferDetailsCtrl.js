moj.Modules.TransferDetailsCtrl = {
  els: {
    fxAutocomplete: '.fx-autocomplete'
  },
  activate: function () {
    return $('#claim_form_step').val() === 'transfer_fee_details'
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
      $.subscribe('/onConfirm/claim_transfer_stage_id-select/', function () {
        moj.Modules.TransferDetailFieldsDisplay.callCaseConclusionController()
      })
    }
  }
}
