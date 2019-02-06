moj.Modules.OffenceCtrl = {
  init: function() {

    //Claim basic section
    this.initBasicClaim();
  },
  initBasicClaim: function() {
    var self = this;
    if ($('#claim_offence_category_description').length) {
      moj.Helpers.Autocomplete.new('#claim_offence_category_description', {
        showAllValues: true,
        autoselect: false
      });
    }

    $.subscribe('/onConfirm/claim_offence_category_description-select/', function(e, data) {
      var param = $.param({
        description: data.query
      });
      $.getScript('/offences?' + param);
    });


    if (!$('#claim_offence_id').val()) {
      $('.offence-class-select').hide();
    }
    self.attachToOffenceClassSelect();
  },
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
