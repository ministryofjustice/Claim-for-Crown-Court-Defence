moj.Modules.FeeFieldsDisplay = {
  init: function() {
    var self = this;
    this.addFeeChangeEvent();
  },

  addFeeChangeEvent: function(el) {
    var self = this;
    var $el = el ? $(el) : $('.fx-fee-group');

    $el.find('select.js-fee-type').each(function() {
      var el = $(this).closest('.fx-fee-group');
      self.showHideFeeFields(el);
    });

    $el.find('.js-typeahead').on('typeahead:change', function() {
      var el = $(this).closest('.fx-fee-group');
      self.showHideFeeFields(el);
    });
  },

  showHideFeeFields: function(el) {
    var self = this;
    var currentElement = $(el);
    var caseNumbersInput = currentElement.find('input.fx-fee-case-numbers');
    var epfAmountRadios = currentElement.find('.fx-fee-amount-radio-section');

    // enable/disable case numbers field
    if (caseNumbersInput.exists()) {
      var showCaseNumbers = currentElement.find('option:selected').data('case-numbers');

      if (showCaseNumbers) {
        caseNumbersInput.prop('readonly', false);
        caseNumbersInput.prop('tabindex', 0);
      } else {
        caseNumbersInput.val('');
        caseNumbersInput.prop('readonly', true);
        caseNumbersInput.prop('tabindex', -1);
      }
    }

    // show/hide Evidence provision fee amount-limiting radios
    if (epfAmountRadios.exists()) {
      self.toggleEpfRadios(el);
    }
  },

  toggleEpfRadios: function(el) {
    var currentElement = $(el);
    var evidenceProvisionFee = currentElement.find('option:selected').data('epf');
    var epfAmountRadios = currentElement.find('.fx-fee-amount-radio-section');
    var epfAmountRadio = currentElement.find('.fx-fee-amount-radio');
    var feeAmount = currentElement.find('.fx-fee-amount-section');
    var feeAmountInput = currentElement.find('.fx-fee-amount');

    if (evidenceProvisionFee) {
      epfAmountRadios.show();
      epfAmountRadio.prop('disabled', false);
      feeAmountInput.prop('disabled', true);
      feeAmount.hide();
    } else {
      epfAmountRadio.prop('disabled', true);
      epfAmountRadios.hide();
      feeAmount.show();
      feeAmountInput.prop('disabled', false);
    }
  },

}