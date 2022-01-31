const selectedOffenceClass = []
moj.Modules.OffenceCtrl = {
  els: {
    offenceClassSelectWrapper: '.js-offence-class-select-wrapper',
    offenceClassSelect: '.js-offence-class-select select',
    offenceID: '#claim_offence_id',
    offenceCategoryDesc: '#claim_offence_category_description'
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
          console.log(param) // description=VAT%20offences
          moj.Modules.OffenceCtrl.test(result)
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
      console.log(selectedOffenceClass)
      self.setValueToOffenceID($(this).val())
    })
  },

  setValueToOffenceID: function (data) {
    if (data) {
      const value = parseInt(data)
      const selectedValue = selectedOffenceClass[0].filter(function (object) {
        return object.id === value
      })
      console.log(selectedValue)
      $(this.els.offenceID).val(selectedValue[0].offence_id)
    } else {
      this.initialiseOffenceID()
    }
  },

  test: function (result) {
    const array = JSON.parse('[' + result + ']')
    console.log(array)
    selectedOffenceClass.push(array[0])
    if (array.length > 0) {
      $(this.els.offenceClassSelectWrapper).show()
      $(this.els.offenceClassSelect).empty()
      $.each(array[0], function (e, data) {
        $(moj.Modules.OffenceCtrl.els.offenceClassSelect).append(
          '<option value=' + data.id + '>' + data.description + '</option>'
        )
      })
    }
  }
}
