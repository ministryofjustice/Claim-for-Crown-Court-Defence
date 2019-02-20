moj.Modules.InterimFeeFieldsDisplay = {
  activate: function() {
    return $('#claim_form_step').val() === 'interim_fees';
  },
  init: function() {
    var self = this;

    if (this.activate()) {
      moj.Modules.CaseTypeCtrl.initAutocomplete();
      this.addInterimFeeChangeEvent();
      $('#interim-fee').find('select.js-interim-fee-type').each(function() {
        self.showHideInterimFeeFields(this);
      });
      this.bindEvents();
    }
  },
  bindEvents: function() {
    var self = this;

    $('#disbursements').on('cocoon:after-insert', function(e, element) {
      var elId = $(element).find('.fx-autocomplete').attr('id');
      moj.Helpers.Autocomplete.new('#' + elId, {
        showAllValues: true,
        autoselect: false
      });
    });
  },
  addInterimFeeChangeEvent: function() {
    var self = this;

    $('#interim-fee').on('change', 'select.js-interim-fee-type', function() {
      self.showHideInterimFeeFields(this);
      $(self.el).trigger('recalculate');
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
