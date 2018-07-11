moj.Modules.NewClaim = {
  init: function() {

    //Claim basic section
    this.initBasicClaim();

    //Attach on submit claim validation
    this.initSubmitValidation();
  },

  initBasicClaim: function() {
    var self = this;

    self.$offenceCategorySelect = $('#claim_offence_category_description');

    self.$offenceCategorySelect.change(function() {
      var param = $.param({
        description: $(this).find(':selected').text()
      });
      $.getScript('/offences?' + param);
    });

    if (!$('#claim_offence_id').val()) {
      $('.offence-class-select').hide();
    }

    self.attachToOffenceClassSelect();
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
  },

  // in use
  attachToOffenceClassSelect: function() {
    $('#offence_class_description').on('change', function() {
      $('#claim_offence_id').val($(this).val());

      if (!$(this).val()) {
        $('.offence-class-select').hide();
        $('#claim_offence_id').val('');
      }
    });
  }
};
