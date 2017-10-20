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
  }
}