"use strict";

var adp = adp || {};

adp.feeCalculator = {
  init : function(container_id) {
    this.addChangeEvent(container_id);
  },
  calculateAmount: function(rate, quantity, modifier) {
    console.log('calculateAmount');
    var r = rate || 0
    var q = ( (quantity || 0) + modifier)
    q = q < 0 ? 0 : q
    return (r * q).toFixed(2);

  },
  addChangeEvent: function(container_id) {
    $('#' + container_id).on('change', '.quantity, .rate', function(e) {

      var wrapper  = $(e.target).closest('.nested-fields');
      var quantity = parseFloat(wrapper.find('.quantity').val());
      var modifier = parseFloat(wrapper.find('.quantity_modifier').text());
      var rate     = parseFloat(wrapper.find('.rate').val());
      var total = adp.feeCalculator.calculateAmount(rate,quantity,modifier);

      if (isNaN(total) ){
        wrapper.find('.amount').text(' ');
      }
      else{
        wrapper.find('.amount').text('£ '+ total);
      }
    });
  }
};
