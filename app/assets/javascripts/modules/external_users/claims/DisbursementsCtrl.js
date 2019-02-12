moj.Modules.DisbursementsCtrl = {
  els:{
    fxAutocomplete: '.fx-autocomplete'
  },
  initAutocomplete: function() {
    var arr = $(this.els.fxAutocomplete);

    $(this.els.fxAutocomplete).is(function(idx, el) {
      moj.Helpers.Autocomplete.new('#' + el.id, {
        showAllValues: true,
        autoselect: false
      });
    });
  },
  init: function() {
    // init the auto complete
    this.initAutocomplete();

    // bind general page events
    this.bindEvents();
  },
  bindEvents: function() {
    var self = this;

    $('#disbursements').on('cocoon:after-insert', function(e, element){
      var elId = $(element).find('.fx-autocomplete').attr('id');
      moj.Helpers.Autocomplete.new('#' + elId, {
        showAllValues: true,
        autoselect: false
      });
    });
  }
};
