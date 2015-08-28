"use strict";

var adp = adp || {};

adp.determination = {
  init : function(container_id) {
    this.addChangeEvent(container_id);

    $(container_id)
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
        adp.redetermination.calculateRow(firstInput);
      })

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
  addChangeEvent: function(container_id) {

    $('#' + container_id).on('change', ':text', function(e) {
      adp.determination.calculateRow(this);
    });
  },
  calculateRow : function(element){
    //Cache the element that triggered the event
    var $element = $(element),
    //Find the row the element is in
    $tr = $element.closest('tr'),
    //Find the fees column
    $fees = $tr.find('.js-fees'),
    //Parse the value
    fees = parseFloat($fees.val().replace(/,/g, "")),
    //Find the Expenses column
    $expenses = $tr.find('.js-expenses'),
    // Parse the value
    expenses = parseFloat($expenses.val().replace(/,/g, "")),
    //Work out the total
    total = adp.determination.calculateAmount(fees,expenses);

    if (isNaN(total) ){
      $('.js-total-determination').text('£0.00');
    }else{
      $('.js-total-determination').text('£ '+ total);
    }
  }
};
