moj.Modules.FeeFieldsDisplay = {
  init: function() {
    this.addFeeChangeEvent($('.fx-fee-group'));
  },
  addFeeChangeEvent: function(el) {
    var self = this;
    var $el = $(el);

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
    var currentElement = $(el);
    var caseNumbersInput = currentElement.find('input.fx-fee-case-numbers');

    if (caseNumbersInput.exists()) {
      var showCaseNumbers = currentElement.find('option:selected').data('case-numbers');
      var caseNumbersWrapper = caseNumbersInput.closest('.case_numbers_wrapper');

      if (showCaseNumbers) {
        caseNumbersWrapper.show();
      } else {
        caseNumbersInput.val('');
        caseNumbersWrapper.hide();
      }
    }
  }
};
