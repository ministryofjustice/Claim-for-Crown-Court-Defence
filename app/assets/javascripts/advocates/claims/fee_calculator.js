"use strict";

var adp = adp || {};

adp.feeCalculator = {
  init : function(container_id) {
    this.addChangeEvent(container_id);
  },
  calculateAmount: function(rate, quantity, modifier) {

    var r = rate || 0;
    var q = (quantity || 0) + (modifier || 0);
    q = q < 0 ? 0 : q;
    var t = (r * q).toFixed(2);
    t = t < 0 ? 0 : t;
    return t;

  },
  addChangeEvent: function(container_id) {
    $('#' + container_id).on('change', '.quantity, .rate', function(e) {

      var wrapper  = $(e.target).closest('.nested-fields');
      var quantity = parseFloat(wrapper.find('.quantity').val());
      var modifier = parseFloat(wrapper.find('.quantity-modifier').text());
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
