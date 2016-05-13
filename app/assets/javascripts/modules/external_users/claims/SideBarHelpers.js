moj.Helpers.SideBar = {
  Base: function(options) {
    var _options = {
      type: '_Base',
      vatfactor: 0.2,
      autoVAT: true
    };
    this.config = $.extend({}, _options, options);
    this.$el = this.config.$el;
    this.el = this.config.el;

    this.getConfig = function(key) {
      return this.config[key] || undefined;
    };

    this.updateTotals = function() {
      return 'This method needs an override';
    };

    this.isVisible = function() {
      return this.$el.find('.rate').is(':visible') || this.$el.find('.amount').is(':visible') || this.$el.find('.total').is(':visible');
    };

    this.applyVat = function() {
      if (this.config.autoVAT) {
        this.totals.vat = this.totals.total * this.config.vatfactor;
      }
    };

    this.getVal = function(selector) {
      return parseFloat(this.$el.find(selector).val()) || 0;
    };

    this.getDataVal = function(selector) {
      return parseFloat(this.$el.find('.' + selector).data('total')) || false;
    };
  },
  FeeBlock: function() {
    // copy methods over
    moj.Helpers.SideBar.Base.apply(this, arguments);
    this.totals = {
      quantity: 0,
      rate: 0,
      amount: 0,
      total: 0,
      vat: 0
    };

    this.reload = function() {
      this.updateTotals();
      this.applyVat();
    };

    this.updateTotals = function() {
      if (!this.isVisible()) {
        return this.totals;
      }
      this.totals = {
        quantity: this.getVal('.quantity'),
        rate: this.getVal('.rate'),
        amount: this.getVal('.amount'),
        total: this.getDataVal('total') || this.getVal('.total'),
        vat: this.getVal('.vat')
      };
      return this.totals;
    };

    this.reload();
  },
  addCommas: function(nStr) {
    nStr += '';
    x = nStr.split('.');
    x1 = x[0];
    x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
      x1 = x1.replace(rgx, '$1' + ',' + '$2');
    }
    return x1 + x2;
  },
};