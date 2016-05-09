moj.Modules.InterimFeeFieldsDisplay = {
  el: '#interim-fee',
  typeSelect: 'select.js-interim-fee-type',

  init: function() {
    var self = this;

    this.addInterimFeeChangeEvent();

    $(this.el).find(this.typeSelect).each(function() {
      self.showHideInterimFeeFields(this);
    });
  },

  addInterimFeeChangeEvent: function() {
    var self = this;

    $(this.el).on('change', self.typeSelect, function() {
      self.showHideInterimFeeFields(this);
    });
  },

  showHideInterimFeeFields: function(elem) {
    var self = this,
      elements = $(elem).find('option:selected').data();

    if (elements) {
      $.each(elements, function(name, val) {
        if (val) {
          $('.js-interim-' + name).show().removeClass('visually-hidden');
        } else {
          $('.js-interim-' + name).hide().find('input, select, textarea').each(function(i, e) {
            $(this).val('').prop('checked', false);
          });
        }
      });
    }
  }
};