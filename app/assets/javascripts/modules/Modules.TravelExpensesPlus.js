moj.Modules.TravelExpensesPlus = {
  el: '.form-section-compound',
  input: '.fx-toggle-input',
  select: '.fx-toggle-select',
  init: function() {
    // var self = this;
    // this.$el = $(this.el);
    // this.$input = $(this.input);
    // this.$select = $(this.select);


    // $.subscribe('/API/expenses/loaded/', function() {
    //   self.bindEvents();
    // });
  },
  bindEvents: function() {
    var self = this;
    this.$el.on('change', '.fx-select-travel-reason', function(e) {
      var $el = $(e.target);
      // console.log($el.find(':selected').data());
      // console.log('Render the correct element based on settings passed as data');
      self.buildElement($el.find(':selected').data('category'));
    });
  },
  buildElement: function(category) {
    var data = moj.Helpers.API.Expenses;

    if(!category) {
      $('#mySelect')
        .find('option')
        .remove()
        .end();
      return;
    }

    $('#mySelect')
      .find('option')
      .remove()
      .end();

    $.each(data.getLocationByCategory(category), function(id, obj) {
      $('#mySelect')
        .append($('<option></option>')
          .attr('value', obj.id)
          .attr('data-postcode', obj.postcode)
          .attr('data-category', obj.category)
          .attr('data-name', obj.name)
          .text(obj.name));
    });
  }
};
