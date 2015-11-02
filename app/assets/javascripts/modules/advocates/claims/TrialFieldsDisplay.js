"use strict";

var moj = moj || {};

moj.Modules.TrialFieldsDisplay = {
  $caseTypeSelect: {},
  $container: {},
  regex: {},

  init : function() {
    var self = this;
    //initialise handles
    this.$caseTypeSelect = $('#claim_case_type_id');
    this.$container = $('#trial-details');
    this.regex = /(Appeal against conviction|Appeal against sentence|Breach of Crown Court order|Committal for Sentence|Contempt|Cracked Trial|Cracked before retrial|Elected cases not proceeded).*/i;

    // add change listener
    this.$caseTypeSelect.change(function(){
      self.addCaseTypeChangeEvent();
    });

    this.addCaseTypeChangeEvent();
  },
  addCaseTypeChangeEvent : function() {
    var caseTypeLabel = this.$caseTypeSelect.find('option:selected').text();
    if (caseTypeLabel) {
      if (this.regex.test(caseTypeLabel) || this.$caseTypeSelect.val() == '') {
        this.$container.hide();
      } else {
        this.$container.slideDown();
      }
    }
  }

};
