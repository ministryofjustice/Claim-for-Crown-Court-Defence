let arrayOfOffenceClass = []
moj.Modules.OffenceCtrl = {
  els: {
    offenceClassSelectWrapper: '.js-offence-class-select-wrapper',
    offenceClassSelect: '.js-offence-class-select select',
    offenceID: '#claim_offence_id',
    offenceCategoryDesc: '#js-claim-offence-category-description'
  },
  init: function () {
    // init the auto complete
    this.autocomplete()

    // check the load state
    // binding events to the dynamic select
    this.checkState()

    // bind general page events
    this.bindEvents()
  },

  checkState: function () {
    if (!$(this.els.offenceID).val()) {
      $(this.els.offenceClassSelectWrapper).hide()
    }
    this.attachToOffenceClassSelect()
  },

  autocomplete: function () {
    if ($(this.els.offenceCategoryDesc).length) {
      moj.Helpers.Autocomplete.new(this.els.offenceCategoryDesc, {
        showAllValues: true,
        autoselect: false
      })
    }
  },

  bindEvents: function () {
    $('.fx-autocomplete-wrapper select').each(function () {
      $.subscribe('/onConfirm/' + this.id + '/', function (e, data) {
        const param = $.param({
          description: data.query
        })
        $.getScript('/offences?' + param).done(function (result) {
          moj.Modules.OffenceCtrl.mapToOffenceClassSelect(result)
        })
      })
    })
  },

  initialiseOffenceID: function () {
    $(this.els.offenceClassSelectWrapper).hide()
    $(this.els.offenceID).val('')
  },

  attachToOffenceClassSelect: function () {
    const self = this
    $(this.els.offenceClassSelect).on('change', function () {
      self.setValueToOffenceID($(this).val())
    })
  },

  setValueToOffenceID: function (data) {
    if (data) {
      const value = parseInt(data)
      const selectedValue = arrayOfOffenceClass.filter(function (object) {
        return object.offence_class.id === value
      })
      $(this.els.offenceID).val(selectedValue[0].id)
    } else {
      this.initialiseOffenceID()
    }
  },

  mapToOffenceClassSelect: function (result) {
    const array = JSON.parse(result)

    if (array.length > 0) {
      $(this.els.offenceClassSelectWrapper).show()
      $(this.els.offenceClassSelect).empty()
      arrayOfOffenceClass = []
      array.map(function (data) {
        $(moj.Modules.OffenceCtrl.els.offenceClassSelect).append(
          '<option value=' + data.offence_class.id + '>' + data.offence_class.class_letter + ': ' + data.offence_class.description + '</option>'
        )
        return arrayOfOffenceClass.push(data)
      })
      this.setValueToOffenceID(array[0].offence_class.id)
    }
  }
}
