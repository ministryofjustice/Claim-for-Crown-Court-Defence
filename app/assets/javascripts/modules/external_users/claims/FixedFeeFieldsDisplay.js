moj.Modules.FixedFeeFieldsDisplay = {
  typeSelect: 'select.js-fixed-fee-type',
  elGroup: '.fixed-fee-group',
  caseNumbersInput: 'input.js-fixed-fee-case-numbers',
  el: '#fixed-fees',
  eventHook: '.js-typeahead',

  init: function() {
    var self = this;
    this.addFixedFeeChangeEvent();
    $(this.el).find(this.typeSelect).each(function() {
      self.showHideFixedFeeFields(this);
    });
  },

  addFixedFeeChangeEvent: function(elem) {
    var self = this;
    elem = elem || this.eventHook;
    $(elem).on('typeahead:change', function() {
      self.showHideFixedFeeFields(this);
    });
  },

  showHideFixedFeeFields: function(elem) {
    var self = this;
    var currentElement = $(elem).closest(self.elGroup);
    var caseNumbersInput = currentElement.find(self.caseNumbersInput);

    if (caseNumbersInput.exists()) {
      var showCaseNumbers = currentElement.find('option:selected').data('case-numbers');

      if (showCaseNumbers) {
        caseNumbersInput.prop('disabled', false);
      } else {
        caseNumbersInput.val('');
        caseNumbersInput.prop('disabled', true);
      }
    }
  }
};