"use strict";

var cbo = cbo || {}

cbo.feeCalculator = {
  init : function(container_id) {
    this.addChangeEvent(container_id);
  },
  addChangeEvent: function(container_id) {
    $('#' + container_id).on('change', '.quantity, .rate', function(e) {
      var wrapper = $(e.target).closest('.nested-fields');
      var quantity = parseFloat(wrapper.find('.quantity').val());
      var rate = parseFloat(wrapper.find('.rate').val());
      var total = (rate * quantity).toFixed(2);
      wrapper.find('.amount').val(total);
    });
  }
}
