moj.Modules.TransferDetailFieldsDisplay = {
  litigatorTypeRadio: '.js-litigator-type',
  electedCaseRadio: '.js-elected-case',
  transferStageSelect: 'select.js-transfer-stage-id',

  init: function() {
    this.addCaseConclusionShowHideEvent();
    this.showHideCaseConclusionField(this);
  },

  addCaseConclusionShowHideEvent: function() {
    var self = this;
    var elements = [this.litigatorTypeRadio, this.electedCaseRadio, this.transferStageSelect];

    elements.forEach( function(el)
    {
      if (typeof(el) !== 'undefined' && el !== null) {
        $(el).on('change', function() {
          self.showHideCaseConclusionField(this);
        });
      }
    });
  },

  getParamVal: function(param_name, selector) {
    if (typeof $(selector) !== 'undefined' && selector !== null) {
      return '&' + param_name + '=' + $(selector).val();
    }
  },

  constructParams: function() {
    var params = '';
    params = params + this.getParamVal('litigator_type', $(this.litigatorTypeRadio+':checked'));
    params = params + this.getParamVal('elected_case', $(this.electedCaseRadio+':checked'));
    params = params + this.getParamVal('transfer_stage_id', $(this.transferStageSelect).find('option:selected'));

    //remove initial &
    return params.substr(1);
  },

  showHideCaseConclusionField: function() {
    var params = this.constructParams();
    $.getScript('/case_conclusions?' + params);
  }
};