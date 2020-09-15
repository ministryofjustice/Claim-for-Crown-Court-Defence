moj.Modules.FeeTypeCtrl = {
  init: function () {
    if ($('#misc-fees').exists()) {
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

    if ($('.fx-unused-materials-warning').exists()) {
      $els.change(function () {
        self.showHideUnusedMaterialWarning(this, self.getFeeTypeSelectUniqueCode(this));
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

  showHideUnusedMaterialWarning: function (context, unique_code) {
    show = (unique_code == 'MIUMO');
    var $warning = $(context).closest('.fx-fee-group').find('.fx-unused-materials-warning');
    show ? $warning.removeClass('js-hidden') : $warning.addClass('js-hidden');
  },

  pageLoad: function () {
    var $radios = $('.fee-type input[type=radio]');
    var self = this;

    $(document).ready(function () {
      $radios.each(function () {
        if ($(this).is(':checked')) {
          self.showHideUnusedMaterialWarning(this, self.getFeeTypeRadioUniqueCode(this));
          console.warn(this, self.getFeeTypeRadioUniqueCode(this))
        }
      });
    });
  }
};
