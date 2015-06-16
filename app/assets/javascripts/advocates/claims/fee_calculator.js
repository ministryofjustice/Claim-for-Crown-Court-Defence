"use strict";

var adp = adp || {}

adp.feeCalculator = {
  init : function(container_id) {
    this.addChangeEvent(container_id);
  },
  addChangeEvent: function(container_id) {
    $('#' + container_id).on('change', '.quantity, .rate', function(e) {
      var wrapper = $(e.target).closest('.nested-fields');
      var quantity = parseFloat(wrapper.find('.quantity').val());
      var rate = parseFloat(wrapper.find('.rate').val());
      var total = (rate * quantity).toFixed(2);
      if (isNaN(total) ){
        wrapper.find('.amount').text(' ');
      }
      else{
        wrapper.find('.amount').text('£ '+ total);
      }
    });
  }
}
