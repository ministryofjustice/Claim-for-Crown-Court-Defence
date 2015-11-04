"use strict";

var moj = moj || {};

moj.Modules.ClaimCompletion = {

  $valueChanged: false,

  init : function() {
    var self = this;

    if($('#claim-form .new_claim').length) {
      $('input, select').change(function(e) {
        if(!self.valueChanged) {
          self.valueChanged = true;

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
