moj.Modules.FeeTypeCtrl = {
  init: function () {
    this.bindEvents();
  },

  bindEvents: function () {
    this.miscFeeTypesSelectChange();
    this.pageLoad();
  },

  getFeeTypeUniqueCode: function (context) {
    return $(context).closest('.fx-fee-group').find('option:selected').data('unique-code');
  },

  // needs to be usable by cocoon:after-insert so can bind to one or many elements
  miscFeeTypesSelectChange: function ($el) {
    var self = this;
    var $els = $el || $('.js-misc-fee-type');

    if ($('.fx-unused-materials-warning').exists()) {
      $els.change(function () {
        self.showHideUnusedMaterialWarning(this);
      });
    }
  },

  showHideUnusedMaterialWarning: function (context) {
    show = (this.getFeeTypeUniqueCode(context) == 'MIUMO');
    var $warning = $(context).closest('.fx-fee-group').find('.fx-unused-materials-warning');
    show ? $warning.removeClass('js-hidden') : $warning.addClass('js-hidden');
  },

  pageLoad: function () {
    var self = this;
    $(document).ready(function () {
      $('.js-fee-type:visible').each(function () {
        self.showHideUnusedMaterialWarning(this);
      });
    });
  }
};
