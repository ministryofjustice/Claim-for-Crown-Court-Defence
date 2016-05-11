moj.Modules.SideBar = {
  el: '.totals-summary',
  claimForm: '#claim-form',
  vatfactor: 0.2,
  totals: {
    fees: 0,
    disbursements: 0,
    expenses: 0,
    vat: 0,
    inc: 0
  },

  init: function() {
    this.bindListeners();
    if ($(this.el).length > 0) {
      this.primeInternalCache();
    }
  },

  bindListeners: function() {
    var self = this;
    $('#claim-form').on('recalculate', function() {
      self.recalculate();
    });
  },

  clearTotals: function() {
    var self = this;
    $.each(this.totals, function(key, val) {
      self.totals[key] = parseFloat(0);
    });
  },

  sanitzeFeeToFloat: function() {
    var self = this;
    $.each(this.totals, function(key, val) {
      if ($.type(self.totals[key]) === 'string') {
        self.totals[key] = parseFloat(self.totals[key].replace(',', '').replace(/£/g, ''));
      }
    });
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

  render: function() {
    var self = this;
    var selector;
    var value;
    this.sanitzeFeeToFloat();
    $.each(this.totals, function(key, val) {
      selector = '.total-' + key;
      value = '£' + self.addCommas(val.toFixed(2));
      $(self.el).find(selector).html(value);
    });
  },

  primeInternalCache: function() {
    var self = this;
    var $el = $(this.el);
    var lookup;
    var found;

    $.each(this.totals, function(key, val) {
      lookup = 'total-' + key;
      hasDataAttr = !!$el.find('.' + lookup).data(lookup);
      self.totals[key] = hasDataAttr ? $el.find('.' + lookup).data(lookup) : parseFloat(0);
    });

    this.render();
  },

  recalculate: function() {
    // console.log('>>Recalculate');
    var self = this;
    // clear the cached this.totals obj
    self.clearTotals();

    // Calculate .mod-fees for visible elements
    $('.mod-fees .nested-fields:visible').each(function(idx, el) {
      // cache the el as $el
      var $el = $(el);
      var amount;
      if (!$el.find('.amount').is(':visible')) {
        return;
      }

      // find the different values and parseFloat them
      amount = parseFloat($el.find('.amount').data('amount') || $el.find('.amount').val()) || 0;

      // Total Fees amount
      self.totals.fees = parseFloat(self.totals.fees + amount);
      self.totals.vat = parseFloat((self.totals.fees + self.totals.expenses) * self.vatfactor);
      self.totals.inc = parseFloat((self.totals.fees + self.totals.vat + self.totals.expenses + self.totals.disbursements));
    });

    $('.mod-expenses .nested-fields:visible').each(function(idx, el) {
      var $el = $(el);
      var amount;
      if (!$el.find('.amount').is(':visible')) {
        return;
      }

      amount = parseFloat($el.find('.amount').val());

      self.totals.expenses = parseFloat(self.totals.expenses + amount);
      self.totals.vat = parseFloat((self.totals.fees + self.totals.expenses) * self.vatfactor);
      self.totals.inc = parseFloat((self.totals.fees + self.totals.vat + self.totals.expenses + self.totals.disbursements));
    });

    self.render();
  }
};