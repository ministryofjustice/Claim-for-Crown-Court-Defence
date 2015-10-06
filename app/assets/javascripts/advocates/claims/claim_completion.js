"use strict";

var adp = adp || {};

adp.claimCompletion = {

  $valueChanged: false,

  init : function() {
    if($('#claim-form .new_claim').length) {
      $('input, select').change(function(e) {
        if(!adp.claimCompletion.valueChanged) {
          adp.claimCompletion.valueChanged = true;

          $.ajax({
            type: 'POST',
            data: { claim_intention : { form_id : $('#claim_form_id').val() } },
            url: '/claim_intentions',
            success : function(data) {
            }
          });
        }
      });
    }
  }
};
