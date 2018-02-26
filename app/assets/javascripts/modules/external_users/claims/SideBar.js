moj.Modules.SideBar = {
  el: '.totals-summary',
  claimForm: '#claim-form',
  vatfactor: 0.2,
  blocks: [],
  totals: {
    fees: 0,
    miscfees: 0,
    disbursements: 0,
    expenses: 0,
    vat: 0,
    grandTotal: 0
  },

  init: function() {
    this.loadCache();
    this.bindListeners();
    this.loadBlocks();
  },

  clean: function(obj) {
    return Object.keys(obj)
      .reduce(function(value, key) {
        obj[key] = parseFloat(obj[key]);
        return obj;
      }, 0);

  },

  loadCache: function() {
    var self = this;
    this.__cache = {}

    $('.fx-seed').is(function() {
      var $this = $(this);
      var data = self.clean($this.data());
      var x = $.extend(self.__cache, data)

    })
    console.log(this.__cache);
    console.log('FIND TYPE C AND KEEP ADDING THE NEW VALUE');
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
        typec: $el.data('typec'),
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
      console.log(selector, value);
      // $(self.el).find(selector).html(value);
    });
  },

  recalculate: function() {
    var self = this;

    this.totals = {
      fees: 0,
      miscfees: 0,
      disbursements: 0,
      expenses: 0,
      vat: 0,
      grandTotal: 0
    };

    this.rawTotals = {
      disbursementTotal: 0,
      expensesTotal: 0,
      fixedFeeDisplay: 0,
      fixedFeeTotal: 0,
      gradFeeTotal: 0,
      miscFeeTotal: 0,
      totalExcl: 0,
      totalInc: 0,
      vatTotal: 0
    };

    self.blocks.forEach(function(block) {
      if (block.isVisible()) {
        block.reload();
        console.log(block.getConfig('type'),block.getConfig('typec'), block);

        self.totals[block.getConfig('type')] += block.totals.typeTotal;
        self.rawTotals[block.getConfig('typec')] += block.totals.typeTotal;

        self.totals.vat += block.totals.vat;
        self.totals.grandTotal += block.totals.typeTotal + block.totals.vat;
      }
    });
    console.log([{raw:this.rawTotals}, {cache:this.__cache}]);
    // self.render();
  },

  bindListeners: function() {
    var self = this;
    $('#claim-form').on('recalculate', function() {
      console.log('recalculate');
      self.recalculate();
    });

    $('#claim-form').on('cocoon:after-insert', function(e) {
      self.loadBlocks();
      self.recalculate();
    });

    $('#claim-form').on('cocoon:after-remove', function(e) {
      self.loadBlocks();
      self.recalculate();
    });

  },

  sanitzeFeeToFloat: function() {
    var self = this;
    $.each(this.totals, function(key, val) {
      if ($.type(self.totals[key]) === 'string') {
        self.totals[key] = self.strAmountToFloat(self.totals[key]);
      }
    });
  },

  strAmountToFloat: function(str) {
    if (typeof str == 'undefined') {
      return 0;
    }
    return parseFloat(str.replace(',', '').replace(/£/g, ''));
  }

};