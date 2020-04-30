moj.Modules.CaseTypeCtrl = {
  activate: function () {
    return $('#claim_form_step').val() === 'case_details';
  },
  els: {
    requiresCrackedDates: '#cracked-trial-dates',
    requiresRetrialDates: '#retrial-dates',
    requiresTrialDates: '#trial-dates',
    fxAutocomplete: '.fx-autocomplete'
  },

  actions: {
    requiresTrialDates: function (param, context) {
      context.toggle(context.els.requiresTrialDates, param);
    },
    requiresRetrialDates: function (param, context) {
      context.toggle(context.els.requiresRetrialDates, param);
    },
    requiresCrackedDates: function (param, context) {
      context.toggle(context.els.requiresCrackedDates, param);
    }
  },

  toggle: function (element, param) {
    return param ? $(element).removeClass('hidden') : $(element).addClass('hidden');
  },

  init: function () {
    if (this.activate()) {

      // bind events
      this.bindEvents();

      // init the autocomplete elements
      this.initAutocomplete();
    }
  },

  bindEvents: function () {
    var self = this;

    $.subscribe('/onConfirm/case_type-select/', function (e, data) {
      // Loop over the data object and fire the
      // methods as required, passing in the param
      Object.keys(data).map(function (objectKey) {
        if (typeof self.actions[objectKey] == 'function') {
          self.actions[objectKey](data[objectKey], self);
        }
      });
    });
  },

  initAutocomplete: function () {
    $(this.els.fxAutocomplete).is(function (idx, el) {
      moj.Helpers.Autocomplete.new('#' + el.id, {
        showAllValues: true,
        autoselect: false
      });
    });
  }
};
