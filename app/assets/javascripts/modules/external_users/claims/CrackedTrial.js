moj.Modules.CrackedTrial = {
  $caseTypeSelect: {},
  $fieldSet: {},
  regex: {},

  init: function () {
      //initialise handles
      this.$caseTypeSelect = $('#claim_case_type_id');
      this.$fieldSet = $('#cracked_trial_detail');
      this.regex = /[Cc]racked .*/;

      if (!(this.$caseTypeSelect.exists() && this.$fieldSet.exists())) {
          return
      }

      // add change listener
      this.$caseTypeSelect.change($.proxy(this.addCaseTypeChangeEvent, this));

      // show fieldset if cracked trial type already selected (i.e. if editing existing claim)
      var caseTypeLabel = this.$caseTypeSelect.find('option:selected').text();
      if (typeof caseTypeLabel === 'undefined' || !this.regex.test(caseTypeLabel)) {
          this.$fieldSet.hide();
      }
  },

  addCaseTypeChangeEvent: function () {
      var caseTypeLabel = this.$caseTypeSelect.find('option:selected').text();
      if (caseTypeLabel) {
          if (this.regex.test(caseTypeLabel)) {
              this.$fieldSet.slideDown();
          } else {
              this.$fieldSet.slideUp();
          }
      }
  }
};
