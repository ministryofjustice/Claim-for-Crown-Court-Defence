moj.Modules.NewClaim = {
  init: function() {
    $.numberedList({
      wrapper: ".fx-numberedList-hook"
    });
    //Attach on submit claim validation
    this.initSubmitValidation();
  },
  initSubmitValidation: function() {
    //
    // Warn the user if 'A copy of the indictment' is not selected in the
    // supporting evidence checklist.
    // Tests in /spec/javascripts/supporting-evidence_spec.js
    //
    $('input[name="commit_submit_claim"]').on('click', function(e) {
      if ($('#claim_evidence_checklist_ids_4').exists() && !$('#claim_evidence_checklist_ids_4').prop('checked') && !$('[data-mute-indictment]').data('mute-indictment')) {
        return confirm(
          "The evidence checklist suggests that no indictment has been attached.\n" +
          "This can lead to your claim being rejected.\n\n" +
          "Do you wish to proceed without attaching an indictment?"
        );
      }
    });
  }
};
