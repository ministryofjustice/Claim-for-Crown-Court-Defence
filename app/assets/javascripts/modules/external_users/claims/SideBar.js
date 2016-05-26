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
      var fn = $el.data('block-type') ? $el.data('block-type') : 'FeeBlock';
      var options = {
        fn: fn,
        type: $el.data('type'),
        autoVAT: $el.data('autovat'),
        el: el,
        $el: $el
      };
      self.blocks.push(new moj.Helpers.SideBar[options.fn](options));
    });
  },

  render: function() {
    var self = this;
    var selector;
    var value;
    this.sanitzeFeeToFloat();
    $.each(this.totals, function(key, val) {
      selector = '.total-' + key;
      value = '&pound;' + moj.Helpers.SideBar.addCommas(val.toFixed(2));
      $(self.el).find(selector).html(value);
    });
  },

  recalculate: function() {
    var self = this;

    this.totals = {
      fees: 0,
      disbursements: 0,
      expenses: 0,
      vat: 0,
      grandTotal: 0
    };

    self.blocks.forEach(function(block) {
      if (block.isVisible()) {
        block.reload();
        self.totals[block.getConfig('type')] += block.totals.typeTotal;
        self.totals.vat += block.totals.vat;
        self.totals.grandTotal += block.totals.typeTotal + block.totals.vat;
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

  sanitzeFeeToFloat: function() {
    var self = this;
    $.each(this.totals, function(key, val) {
      if ($.type(self.totals[key]) === 'string') {
        self.totals[key] = parseFloat(self.totals[key].replace(',', '').replace(/£/g, ''));
      }
    });
  }
};