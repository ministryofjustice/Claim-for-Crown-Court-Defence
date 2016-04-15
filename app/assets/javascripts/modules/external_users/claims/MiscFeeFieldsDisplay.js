moj.Modules.MiscFeeFieldsDisplay = {
    el: '#misc-fees',
    elGroup: '.misc-fee-group',
    typeSelect: 'select.js-misc-fee-type',
    caseNumbersInput: 'input.js-misc-fee-case-numbers',

    init: function () {
        var self = this;

        this.addMiscFeeChangeEvent();

        $(this.el).find(this.typeSelect).each(function () {
            self.showHideMiscFeeFields(this);
        });
    },

    addMiscFeeChangeEvent: function () {
        var self = this;

        $(this.el).on('change', self.typeSelect, function () {
            self.showHideMiscFeeFields(this);
        });
    },

    showHideMiscFeeFields: function (elem) {
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
