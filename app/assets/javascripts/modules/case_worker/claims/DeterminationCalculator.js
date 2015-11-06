moj.Modules.DeterminationCalculator = {
  el: '#determinations',

  init : function() {
    this.addChangeEvent();
    var self = this;

    $(this.el)
      //Find all the rows
      .find('tr')
      //that have input fields
      .has(':text')
      //Work out the total for each row
      .each(function(){
        //cache the current row
        var $tr = $(this),
        //get the first text element
        firstInput = $tr.find(':text').get(0);

        //Calculate the rows total.
        self.calculateRow(firstInput);
      });

  },
  calculateAmount: function(fee, expenses) {

    var f = fee || 0,
      e = expenses || 0;
    f = f < 0 ? 0 : f;
    e = e < 0 ? 0 : e;
    var t = (f + e).toFixed(2);
    t = t < 0 ? 0 : t;
    return t;

  },
  addChangeEvent: function() {
    var self = this;
    $(this.el).on('change', ':text', function(e) {
      self.calculateRow(this);
    });
  },
  calculateRow : function(element){
    //Cache the element that triggered the event
    var $element = $(element),
    //Find the row the element is in
    $table = $element.closest('table'),
    //Find the fees column
    $fees = $table.find('.js-fees'),
    //Parse the value
    fees = parseFloat($fees.val().replace(/,/g, "")),
    //Find the Expenses column
    $expenses = $table.find('.js-expenses'),
    // Parse the value
    expenses = parseFloat($expenses.val().replace(/,/g, "")),
    //Work out the total
    total = this.calculateAmount(fees,expenses);

    if (isNaN(total) ){
      $('.js-total-determination').text('£0.00');
    }else{
      $('.js-total-determination').text('£ '+ total);
    }
  }
};
