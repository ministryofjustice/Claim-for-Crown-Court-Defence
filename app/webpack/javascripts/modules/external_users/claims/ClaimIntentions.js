moj.Modules.ClaimIntentions = {
  $valueChanged: false,

  init: function () {
    var self = this;

    if ($('#claim-form .new_claim').exists() && !$('div.error-summary').exists()) {
      $('input, select').change(function() {
        if (!self.valueChanged) {
          self.valueChanged = true;

          $.ajax({
            type: 'POST',
            data: {claim_intention: {form_id: $('#claim_form_id').val()}},
            url: '/claim_intentions',
            success: function (data) {
            }
          });
        }
      });
    }
  }
};
