moj.Modules.TransferDetailFieldsDisplay = {
  tdWrapper: '.js-case-conclusion-effectors',
  $tdWrapper: null,
  litigatorTypeRadio: '.js-litigator-type',
  electedCaseRadio: '.js-elected-case',
  transferStageSelect: 'select.js-transfer-stage-id',
  caseConclusionSelect: '.js-case-conclusions-select',

  init: function() {
    if ($(this.tdWrapper).length > 0) {
      this.$tdWrapper = $(this.tdWrapper);
      this.addCaseConclusionShowHideEvent();
      this.showHideCaseConclusionField();
    }
  },

  addCaseConclusionShowHideEvent: function() {
    var self = this;
    var elements = [this.litigatorTypeRadio,
                    this.electedCaseRadio,
                    this.transferStageSelect
                    ].join(',');
    this.$tdWrapper.on('change', elements, function() {
      self.showHideCaseConclusionField();
    });
  },

  caseConclusionToggle: function(toggle) {
    if (toggle) {
      $(this.caseConclusionSelect).slideDown();
    } else {
      $(this.caseConclusionSelect + ' select').val(''); // reset actual select list value
      $('#claim_case_conclusion_id_autocomplete').val(''); // reset awesomplete displayed value
      $(this.caseConclusionSelect).hide();
    }
  },

  getParamVal: function(param_name, selector) {
    if (typeof $(selector) !== 'undefined' && selector !== null) {
      return '&' + param_name + '=' + $(selector).val();
    }
  },

  constructParams: function() {
    var params = '';
    params = params + this.getParamVal('litigator_type',    this.$tdWrapper.find(this.litigatorTypeRadio + ':checked'));
    params = params + this.getParamVal('elected_case',      this.$tdWrapper.find(this.electedCaseRadio + ':checked'));
    params = params + this.getParamVal('transfer_stage_id', this.$tdWrapper.find(this.transferStageSelect).find('option:selected'));

    //remove initial &
    return params.substr(1);
  },

  showHideCaseConclusionField: function() {
    var params = this.constructParams();
    $.getScript('/case_conclusions?' + params);
  }
};