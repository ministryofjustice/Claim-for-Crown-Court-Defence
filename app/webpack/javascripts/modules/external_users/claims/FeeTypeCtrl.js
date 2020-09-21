moj.Modules.FeeTypeCtrl = {
  activate: function () {
    return $('#claim_form_step').val() === 'miscellaneous_fees';
  },

  init: function () {
    if (this.activate()) {
      this.bindEvents();
    }
  },

  bindEvents: function () {
    this.miscFeeTypesSelectChange();
    this.miscFeeTypesRadioChange();
    this.miscFeeTypesCheckboxChange();
    this.pageLoad();
  },

  getFeeTypeSelectUniqueCode: function (context) {
    return $(context).closest('.fx-fee-group').find('option:selected').data('unique-code');
  },

  getFeeTypeRadioUniqueCode: function (context) {
    return $(context).closest('.fx-fee-group').find(':checked').data('unique-code');
  },

  getFeeTypeCheckboxUniqueCode: function (context) {
    return $(context).closest('.fx-fee-group').find(':checked').data('unique-code');
  },

  // needs to be usable by cocoon:after-insert so can bind to one or many elements
  miscFeeTypesSelectChange: function ($el) {
    var self = this;
    var $els = $el || $('.fx-fee-group');

    if ($('.fx-unused-materials-warning').exists()) {
      $els.change(function () {
        self.showHideUnusedMaterialWarning(this, self.getFeeTypeSelectUniqueCode(this));
      });
    }
    if ($('.fee-quantity').exists()) {
      $els.change(function () {
        self.readOnlyQuantity(this, self.getFeeTypeSelectUniqueCode(this));
      });
    }
  },

  // needs to be usable by cocoon:after-insert so can bind to one or many elements
  miscFeeTypesRadioChange: function ($el) {
    var self = this;
    var $els = $el || $('.fx-fee-group');

    if ($('.fx-unused-materials-warning').exists()) {
      $els.change(function () {
        self.showHideUnusedMaterialWarning(this, self.getFeeTypeRadioUniqueCode(this));
      });
    }
  },

  miscFeeTypesCheckboxChange: function ($el) {
    var self = this;
    var $els = $el || $('.fx-fee-group');

    if ($('input.fee-quantity').exists()) {
      $els.change(function () {
        self.readOnlyQuantity(this, self.getFeeTypeCheckboxUniqueCode(this));
      });
    }
  },

  showHideUnusedMaterialWarning: function (context, unique_code) {
    show = (unique_code == 'MIUMO');
    var $warning = $(context).closest('.fx-fee-group').find('.fx-unused-materials-warning');
    show ? $warning.removeClass('js-hidden') : $warning.addClass('js-hidden');
  },

  readOnlyQuantity: function (context, unique_code) {
    readOnly = (unique_code == 'MIUMU');
    var defaultQuantity = 1;
    var $quantity = $(context).closest('.fx-fee-group').find('input.fee-quantity');
    if(readOnly){
      $quantity.val(defaultQuantity);
      $quantity.attr('readonly', true);
    } else {
      $quantity.val();
      $quantity.removeAttr('readonly');
    }
  },

  pageLoad: function () {
    var self = this;

    $(document).ready(function () {
      $('.js-fee-type:visible').each(function () {
        self.showHideUnusedMaterialWarning(this, self.getFeeTypeSelectUniqueCode(this));
        self.readOnlyQuantity(this, self.getFeeTypeSelectUniqueCode(this));
      });

      $('.fee-type input[type=radio]:checked').each(function() {
        self.showHideUnusedMaterialWarning(this, self.getFeeTypeRadioUniqueCode(this));
      });

      $('.multiple-choice input[type=checkbox]:checked').each(function() {
        self.showHideUnusedMaterialWarning(this, self.getFeeTypeCheckboxUniqueCode(this));
      });

    });
  }
};
