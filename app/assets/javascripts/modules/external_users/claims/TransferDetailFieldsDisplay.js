moj.Modules.TransferDetailFieldsDisplay = {
  tdWrapper: '.js-case-conclusion-effectors',
  $tdWrapper: null,
  litigatorTypeRadio: '.js-litigator-type',
  electedCaseRadio: '.js-elected-case',
  transferStageSelect: 'select.js-transfer-stage-id',
  caseConclusionSelect: '.js-case-conclusions-select',
  transferStageLabel: '.js-transfer-stage-label',
  transferDateLabel: '.js-transfer-date-label',
  params: {},

  init: function() {
    if ($(this.tdWrapper).length > 0) {
      this.cacheEls();
      this.$tdWrapper = $(this.tdWrapper);
      this.addChangeEvent();
      this.callCaseConclusionController();
    }
  },

  cacheEls: function() {
    this.params = {
      litigator_type:{
        el: this.litigatorTypeRadio,
        selector: ':checked'
      },
      elected_case:{
        el: this.electedCaseRadio,
        selector: ':checked'
      },
      transfer_stage_id:{
        el: this.transferStageSelect,
        selector: ' option:selected'
      }
    };
  },

  addChangeEvent: function() {
    var self = this;
    var elements = [this.litigatorTypeRadio,
                    this.electedCaseRadio,
                    this.transferStageSelect
                    ].join(',');
    this.$tdWrapper.on('change', elements, function() {
      self.callCaseConclusionController();
    });
  },

  // called by controller js view render
  caseConclusionToggle: function(toggle) {
    if (toggle) {
      $(this.caseConclusionSelect).slideDown();
    } else {
      $(this.caseConclusionSelect + ' select').val(''); // reset actual select list value
      $('#claim_case_conclusion_id_autocomplete').val(''); // reset awesomplete displayed value
      $(this.caseConclusionSelect).hide();
    }
  },

  // called by controller js view render
  labelTextToggle: function(transfer_stage_label_text,transfer_date_label_text) {
    this.$tdWrapper.find(this.transferStageLabel).text(transfer_stage_label_text);
    this.$tdWrapper.find(this.transferDateLabel).text(transfer_date_label_text);
  },

  getParamVal: function(param_key) {
    var selector = this.params[param_key].el + this.params[param_key].selector;
    return '&' + param_key + '=' + $(this.$tdWrapper.find(selector)).val();
  },

  constructParams: function() {
    var self = this;
    var params = '';
    $.each(this.params, function(key){
      params += self.getParamVal(key);
    });

    //remove initial &
    return params.substr(1);
  },

  callCaseConclusionController: function() {
    var params = this.constructParams();
    $.getScript('/case_conclusions?' + params);
  }
};
