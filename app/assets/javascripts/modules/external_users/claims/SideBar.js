moj.Modules.SideBar = {
  el: '.totals-summary',
  claimForm: '#claim-form',
  vatfactor: 0.2,
  blocks: [],
  totals: {
    fees: 0,
    disbursements: 0,
    expenses: 0,
    vat: 0,
    grandTotal: 0
  },

  init: function() {
    this.bindListeners();
    this.loadBlocks();
  },

  loadBlocks: function() {
    var self = this;
    self.blocks = [];
    $('.js-block').each(function(id, el) {
      var $el = $(el);
      self.blocks.push(new moj.Helpers.SideBar.FeeBlock({
        type: $el.data('type'),
        autoVAT: $el.data('autovat'),
        el: el,
        $el: $el
      }));
    });
  },

  addCommas: function(nStr) {
    nStr += '';
    var x = nStr.split('.');
    var x1 = x[0];
    var x2 = x.length > 1 ? '.' + x[1] : '';
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
      value = '£' + moj.Helpers.SideBar.addCommas(val.toFixed(2));
      $(self.el).find(selector).html(value);
    });
  },

  recalculate: function() {
    var self = this;
    self.clearTotals();

    self.blocks.forEach(function(block) {
      if (block.isVisible()) {
        block.reload();
        self.totals[block.getConfig('type')] += block.totals.total;
        self.totals.vat += block.totals.vat;
        self.totals.grandTotal += block.totals.total + block.totals.vat;
      }
    });

    self.render();
  },

  bindListeners: function() {
    var self = this;
    $('#claim-form').on('recalculate', function() {
      self.recalculate();
    });

    $('#claim-form').on('cocoon:after-insert', function(e) {
      self.loadBlocks();
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

};