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
    this.pageLoad();
  },

  getFeeTypeSelectUniqueCode: function (context) {
    return $(context).closest('.fx-fee-group').find('option:selected').data('unique-code');
  },

  getFeeTypeRadioUniqueCode: function (context) {
    return $(context).closest('.fx-fee-group').find(':checked').data('unique-code');
  },

  // needs to be usable by cocoon:after-insert so can bind to one or many elements
  miscFeeTypesSelectChange: function ($el) {
    var self = this;
    var $els = $el || $('.fx-fee-group');
    alert('here');

    if ($('.fx-unused-materials-warning').exists()) {
      $els.change(function () {
        alert('unused materials');
        self.showHideUnusedMaterialWarning(this, self.getFeeTypeSelectUniqueCode(this));
      });
    }
    // if ($('.fx-quantity').exists()) {
    //   $els.change(function () {
    //     alert('quantity');
    //     self.showHideQuantity(this, self.getFeeTypeSelectUniqueCode(this));
    //   });
    // }
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

  showHideUnusedMaterialWarning: function (context, unique_code) {
    show = (unique_code == 'MIUMO');
    var $warning = $(context).closest('.fx-fee-group').find('.fx-unused-materials-warning');
    show ? $warning.removeClass('js-hidden') : $warning.addClass('js-hidden');
  },

  showHideQuantity: function (context, unique_code) {
    hide = (unique_code == 'MIUMU');
    var $quantity = $(context).closest('.fx-fee-group').find('.fx-quantity');
    hide ? $quantity.addClass('js-hidden') : $quantity.removeClass('js-hidden');
  },

  pageLoad: function () {
    var self = this;

    $(document).ready(function () {
      $('.js-fee-type:visible').each(function () {
        self.showHideUnusedMaterialWarning(this, self.getFeeTypeSelectUniqueCode(this));
      });

      $('.fee-type input[type=radio]:checked').each(function() {
        self.showHideUnusedMaterialWarning(this, self.getFeeTypeRadioUniqueCode(this));
      });
    });
  }
};
