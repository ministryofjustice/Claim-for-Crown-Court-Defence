moj.Modules.CaseTypeCtrl = {
  activate: function() {
    return $('#claim_form_step').val() === 'case_details';
  },
  els: {
    requiresCrackedDates: '#cracked-trial-dates',
    requiresRetrialDates: '#retrial-dates',
    requiresTrialDates: '#trial-dates',
    fxAutocomplete: '.fx-autocomplete'
  },

  actions: {
    requiresTrialDates: function(param, context) {
      context.toggle(context.els.requiresTrialDates, param);
    },
    requiresRetrialDates: function(param, context) {
      context.toggle(context.els.requiresRetrialDates, param);
    },
    requiresCrackedDates: function(param, context) {
      context.toggle(context.els.requiresCrackedDates, param);
    }
  },

  toggle: function(element, param) {
    return $(element).css('display', param ? 'block' : 'none');
  },

  init: function() {
    if (this.activate()) {

      // bind events
      this.bindEvents();

      // init the autocomplete elements
      this.initAutocomplete();
    }
  },

  bindEvents: function() {
    var self = this;

    $('form').on('submit', function() {
      return self.autocompletePolyfill();
    });


    $.subscribe('/onConfirm/claim_case_type_id-select/', function(e, data) {
      // Loop over the data object and fire the
      // methods as required, passing in the param
      Object.keys(data).map(function(objectKey) {
        if (typeof self.actions[objectKey] == 'function') {
          self.actions[objectKey](data[objectKey], self);
        }
      });
    });
  },
  autocompletePolyfill: function () {
    var courtValue = $('#claim_court_id').val();
    var caseValue = $('#claim_case_type_id').val();


      if (!$('#claim_court_id-select').val() || courtValue !== $('#claim_court_id-select').find(':selected').text()) {
        $('#claim_court_id-select option').is(function(idx, option) {
          if (option.text === courtValue) {
            $(option).prop('selected', true);
          }
        });
      }

      if (!$('#claim_case_type_id-select').val() || caseValue !== $('#claim_case_type_id-select').find(':selected').text()) {
        $('#claim_case_type_id-select option').is(function(idx, option) {
          if (option.text === caseValue) {
            $(option).prop('selected', true);
          }
        });
      }
      return true;
  },
  initAutocomplete: function() {
    $(this.els.fxAutocomplete).is(function(idx, el) {
      moj.Helpers.Autocomplete.new('#' + el.id, {
        showAllValues: true,
        autoselect: false
      });
    });
  }
};
