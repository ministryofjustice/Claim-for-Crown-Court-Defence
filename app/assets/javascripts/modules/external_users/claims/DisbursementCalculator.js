moj.Modules.DisbursementCalculator = {
  el: '#disbursements',
  net: 'input[data-calculator=net]',
  vat: 'input[data-calculator=vat]',
  total: '[data-calculator=total]',

  init : function() {
    this.addChangeEvent();
  },

  calculateTotal: function(net_amount, vat_amount) {
    var net = net_amount || 0;
    var vat = vat_amount || 0;
    var t = (net + vat).toFixed(2);
    return (t < 0 ? 0 : t);
  },

  addChangeEvent: function() {
    var self = this;

    $(this.el).on('keyup', [self.net, self.vat], function(e) {
      var wrapper  = $(e.target).closest('.nested-fields');
      var net = parseFloat(wrapper.find(self.net).val());
      var vat = parseFloat(wrapper.find(self.vat).val());
      var total = self.calculateTotal(net, vat);

      if (isNaN(total)) {
        wrapper.find(self.total).text(' ');
      } else {
        wrapper.find(self.total).text('£ '+ total);
      }
    });
  }
};
