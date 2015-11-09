moj.Modules.TrialFieldsDisplay = {
  $caseTypeSelect: {},

  init : function() {
    var self = this;
    //initialise handles
    this.$caseTypeSelect = $('#claim_case_type_id');

    // add change listener
    this.$caseTypeSelect.change(function(){
      self.caseTypeChanged();
    });

    this.caseTypeChanged();
  },
  caseTypeChanged : function() {
    if(this.$caseTypeSelect.val()) {
      $.getScript("/case_types/" + this.$caseTypeSelect.val());
    }
    else {
      $('#trial-details').hide();
    }
  }
};
