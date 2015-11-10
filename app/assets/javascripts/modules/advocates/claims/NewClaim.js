moj.Modules.NewClaim = {
  init : function() {
    this.$offenceCategorySelect = $('#offence_category_description');

    this.$offenceCategorySelect.change(function() {
      var selectedText = $(this).find(':selected').text();
      $.getScript('/offences?description=' + selectedText);
    });

    if(!$('#claim_offence_id').val()) {
      $('.offence-class-select').hide();
      this.$offenceCategorySelect.change();
    }
    else {
      $('#offence_class_description').select2('val', $('#claim_offence_id').val(  ));
    }

    this.attachToOffenceClassSelect();
  },
  attachToOffenceClassSelect : function() {
    $('#offence_class_description').change(function() {
      $('#claim_offence_id').val($(this).val());
    });

    $('#offence_class_description').change();
  }
};
