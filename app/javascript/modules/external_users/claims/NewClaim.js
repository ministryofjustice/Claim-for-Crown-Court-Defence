/* global confirm */

moj.Modules.NewClaim = {
  init: function () {
    $('.fx-numberedList-hook').numberedList()
    // Attach on submit claim validation
    this.initSubmitValidation()
  },
  initSubmitValidation: function () {
    //
    // Warn the user if 'Copy of the indictment' is not selected in the
    // supporting evidence checklist.
    // Tests in /spec/javascripts/supporting-evidence_spec.js
    //
    $('button[name="commit_submit_claim"]').on('click', function (e) {
      if ($('#claim-evidence-checklist-ids-4-field').exists() && !$('#claim-evidence-checklist-ids-4-field').prop('checked') && !$('[data-mute-indictment]').data('mute-indictment')) {
        return confirm(
          'The evidence checklist suggests that no indictment has been attached.\n' +
          'This can lead to your claim being rejected.\n\n' +
          'Do you wish to proceed without attaching an indictment?'
        )
      }
    })
  }
}
