moj.Modules.OffenceCtrl = {
  els: {
    offenceClassSelectWrapper: '.offence-class-select',
    offenceClassSelect: '#offence_class_description',
    offenceID: '#claim_offence_id',
    offenceCategoryDesc: '#claim_offence_category_description'
  },
  init: function() {
    // init the auto complete
    this.autocomplete();

    // check the load state
    // binding events to the dynamic select
    this.checkState();

    // bind general page events
    this.bindEvents();
  },

  checkState: function() {
    if (!$(this.els.offenceID).val()) {
      $(this.els.offenceClassSelectWrapper).hide();
    }
    this.attachToOffenceClassSelect();
  },

  autocomplete: function() {
    if ($(this.els.offenceCategoryDesc).length) {
      moj.Helpers.Autocomplete.new(this.els.offenceCategoryDesc, {
        showAllValues: true,
        autoselect: false
      });
    }
  },

  bindEvents: function() {
    var self = this;
    $.subscribe('/onConfirm/claim_offence_category_description-select/', function(e, data) {
      var param = $.param({
        description: data.query
      });
      $.getScript('/offences?' + param);
    });
  },

  attachToOffenceClassSelect: function() {
    var self = this;
    $(this.els.offenceClassSelect).on('change', function() {
      $(self.els.offenceID).val($(this).val());
      if (!$(this).val()) {
        $(self.els.offenceClassSelectWrapper).hide();
        $(self.els.offenceID).val('');
      }
    });
  }
};
