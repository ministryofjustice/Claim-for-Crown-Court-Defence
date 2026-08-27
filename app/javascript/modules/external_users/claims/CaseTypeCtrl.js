moj.Modules.CaseTypeCtrl = {
  activate: function () {
    return $('#claim_form_step').val() === 'case_details'
  },
  els: {
    requiresCrackedDates: '#cracked-trial-dates',
    requiresRetrialDates: '#retrial-dates',
    requiresTrialDates: '#trial-dates',
    fxAutocomplete: '.fx-autocomplete',
    fxAutocompleteSelect: '.fx-autocomplete-wrapper select'
  },

  actions: {
    requiresTrialDates: function (param, context) {
      context.toggle(context.els.requiresTrialDates, param)
    },
    requiresRetrialDates: function (param, context) {
      context.toggle(context.els.requiresRetrialDates, param)
    },
    requiresCrackedDates: function (param, context) {
      context.toggle(context.els.requiresCrackedDates, param)
    }
  },

  toggle: function (element, param) {
    return param ? $(element).removeClass('hidden') : $(element).addClass('hidden')
  },

  init: function () {
    if (this.activate()) {
      // bind events
      this.bindEvents()

      // init the autocomplete elements
      this.initAutocomplete()
    }
  },

  bindEvents: function () {
    const self = this

    $('.fx-autocomplete-wrapper select').each(function () {
      $.subscribe('/onConfirm/' + this.id + '/', function (e, data) {
        // Loop over the data object and fire the
        // methods as required, passing in the param
        self.eventCallback(e, data)
      })
    })
  },

  eventCallback: function (_e, data) {
    const self = this

    Object.keys(data).map(function (objectKey) {
      return typeof self.actions[objectKey] === 'function' ? self.actions[objectKey](data[objectKey], self) : null
    })
  },

  initAutocomplete: function () {
    $(this.els.fxAutocomplete).is(function (_idx, el) {
      moj.Helpers.Autocomplete.new('#' + el.id, {
        showAllValues: true,
        autoselect: true
      })
    })
  }
}
