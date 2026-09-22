moj.Modules.TransferDetailFieldsDisplay = {
  tdWrapper: '.js-case-conclusion-effectors',
  $tdWrapper: null,
  litigatorTypeRadio: '.js-litigator-type input[type="radio"]',
  electedCaseRadio: '.js-elected-case input[type="radio"]',
  transferStageSelect: 'select.js-transfer-stage-id',
  caseConclusionSelect: '.js-case-conclusions-select',
  transferStageLabel: '.js-transfer-stage-label',
  transferDateLabel: '.js-transfer-date legend',
  params: {},

  init: function () {
    if ($(this.tdWrapper).length > 0) {
      this.cacheEls()
      this.$tdWrapper = $(this.tdWrapper)
      this.addChangeEvent()
      this.callCaseConclusionController()
    }
  },

  cacheEls: function () {
    this.params = {
      litigator_type: {
        el: this.litigatorTypeRadio,
        selector: ':checked'
      },
      elected_case: {
        el: this.electedCaseRadio,
        selector: ':checked'
      },
      transfer_stage_id: {
        el: this.transferStageSelect,
        selector: ' option:selected'
      }
    }
  },

  addChangeEvent: function () {
    const self = this
    const elements = [this.litigatorTypeRadio,
      this.electedCaseRadio,
      this.transferStageSelect
    ].join(',')
    this.$tdWrapper.on('change', elements, function () {
      self.callCaseConclusionController()
    })
  },

  // called by controller js view render
  caseConclusionToggle: function (toggle) {
    if (toggle) {
      $(this.caseConclusionSelect).removeClass('hidden')
    } else {
      $(this.caseConclusionSelect + ' select').prop('selectedIndex', 0) // reset actual select list value
      $(this.caseConclusionSelect + ' .autocomplete__input').val('') // reset autocomplete displayed value
      $(this.caseConclusionSelect).addClass('hidden')
    }
  },

  // called by controller js view render
  labelTextToggle: function (transferStageLabelText, transferDateLabelText) {
    this.$tdWrapper.find(this.transferStageLabel).text(transferStageLabelText)
    this.$tdWrapper.find(this.transferDateLabel).text(transferDateLabelText)
  },

  getParamVal: function (paramKey) {
    const selector = this.params[paramKey].el + this.params[paramKey].selector
    return '&' + paramKey + '=' + $(this.$tdWrapper.find(selector)).val()
  },

  constructParams: function () {
    const self = this
    let params = ''
    $.each(this.params, function (key) {
      params += self.getParamVal(key)
    })
    // remove initial &
    return params.substring(1)
  },

  callCaseConclusionController: function () {
    const params = this.constructParams()
    $.getScript('/case_conclusions?' + params)
  }
}
