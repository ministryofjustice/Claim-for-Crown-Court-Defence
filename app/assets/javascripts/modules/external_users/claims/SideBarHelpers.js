moj.Helpers.SideBar = {
  Base: function(options) {
    var _options = {
      type: '_Base',
      vatfactor: 0.2,
      autoVAT: false
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
    var self = this;
    // copy methods over
    moj.Helpers.SideBar.Base.apply(this, arguments);
    this.totals = {
      quantity: 0,
      rate: 0,
      amount: 0,
      total: 0,
      vat: 0
    };

    this.init = function() {
      this.config.fn = 'FeeBlock';
      this.bindRecalculate();
      this.reload();
      return this;
    };

    this.bindRecalculate = function() {
      this.$el.on('change', '.quantity, .rate, .amount, .vat, .total', function(e) {
        self.$el.trigger('recalculate');
      });
    };

    this.reload = function() {
      this.updateTotals();
      this.applyVat();
      return this;
    };

    this.setTotals = function() {
      this.totals = {
        quantity: this.getVal('.quantity'),
        rate: this.getVal('.rate'),
        amount: this.getVal('.amount'),
        total: this.getDataVal('total') || this.getVal('.total'),
        vat: this.getVal('.vat')
      };

      this.totals.typeTotal = this.totals.total;
      return this.totals;
    };

    this.updateTotals = function(a) {
      if (!this.isVisible()) {
        return this.totals;
      }
      return this.setTotals();
    };

    this.render = function() {
      this.$el.find('.total').html('&pound;' + moj.Helpers.SideBar.addCommas(this.totals.total.toFixed(2)));
      this.$el.find('.total').data('total', this.totals.total);
    };


  },
  FeeBlockCalculator: function() {
    var self = this;
    moj.Helpers.SideBar.FeeBlock.apply(this, arguments);

    this.init = function() {
      this.config.fn = 'FeeBlockCalculator';
      this.bindRecalculate();
      this.bindRender();
      this.reload();
      return this;
    };

    this.setTotals = function() {
      this.totals = {
        quantity: this.getVal('.quantity'),
        rate: this.getVal('.rate'),
        amount: this.getVal('.amount'),
        total: parseFloat((this.getVal('.quantity') * this.getVal('.rate')).toFixed(2)),
        vat: this.getVal('.vat')
      };

      this.totals.typeTotal = this.totals.total;
      return this.totals;
    };

    this.bindRender = function() {
      this.$el.on('change', '.quantity, .rate', function() {
        self.updateTotals();
        self.render();
      });
    };


  },
  FeeBlockManualAmounts: function() {
    var self = this;
    moj.Helpers.SideBar.FeeBlock.apply(this, arguments);

    this.init = function() {
      this.config.fn = 'FeeBlockManualAmounts';

      this.bindRecalculate();
      this.reload();

      this.bindRender();
      this.setTotals();
      return this;
    };

    this.setTotals = function() {
      this.totals = {
        quantity: this.getVal('.quantity'),
        rate: this.getVal('.rate'),
        amount: this.getVal('.amount'),
        total: parseFloat((this.getVal('.amount') + this.getVal('.vat')).toFixed(2)),
        vat: this.getVal('.vat')
      };
      this.totals.typeTotal = this.totals.amount;
      return this.totals;
    };

    this.bindRender = function() {
      this.$el.on('change', '.amount, .vat', function() {
        self.updateTotals();
        self.render();
      });
    };


  },
  PhantomBlock: function() {
    var self = this;
    // copy methods over
    moj.Helpers.SideBar.Base.apply(this, arguments);
    this.totals = {
      quantity: 0,
      rate: 0,
      amount: 0,
      total: 0,
      vat: 0
    };

    this.isVisible = function() {
      return true;
    };

    this.reload = function() {
      this.totals.total = (parseFloat(this.$el.data('seed')) || 0);
      this.totals.typeTotal = this.totals.total;

      if (this.config.autoVAT) {
        this.totals.vat = this.totals.total * 0.2;
      } else {
        this.totals.vat = (parseFloat(this.$el.data('seed-vat')) || 0)
      }
      return this;
    };

    this.init = function() {
      this.reload();
      return this;
    }


  },
  ExpenseBlock: function() {
    var self = this;
    moj.Helpers.SideBar.FeeBlock.apply(this, arguments);

    this.stateLookup = {
      "vatAmount": ".fx-travel-vat-amount",
      "reason": ".fx-expense-reason",
      "netAmount": ".fx-travel-net-amount",
      "location": ".fx-travel-location",
      "hours": ".fx-travel-hours",
      "distance": ".fx-travel-distance",
      "destination": ".fx-travel-destination",
      "date": ".fx-travel-date",
      "cost": ".fx-travel-cost",
      "grossAmount": ".fx-travel-gross-amount"
    }

    this.defaultstate = {
      "grossAmount": false,
      "vatAmount": false,
      "reason": false,
      "netAmount": false,
      "mileage": false,
      "location": false,
      "hours": false,
      "distance": false,
      "destination": false,
      "date": false,
      "cost": false,
      "additionalInfo": false
    }

    this.init = function() {
      this.config.fn = 'ExpenseBlock';
      this.bindRecalculate();
      this.bindEvents();
      this.reload();
      return this;
    };

    this.bindEvents = function() {
      this.bindRender();
      this.bindListners();
    };

    this.bindListners = function() {
      var self = this;

      /**
       * Listen for the `expense type` change event and
       * pass the event object to the statemanager
       */
      this.$el.on('change', '.fx-travel-expense-type select', function(e) {
        self.statemanager(e);
      });
      return this;
    };


    this.bindRender = function() {
    };

    this.setTotals = function() {
      this.totals = {
        quantity: this.getVal('.quantity'),
        rate: this.getVal('.rate'),
        amount: this.getVal('.amount'),
        total: this.getVal('.rate'),
        vat: this.getVal('.vat')
      };

      this.totals.typeTotal = this.totals.total;
      return this.totals;
    };




    /**
     * statemanager: Controlling the visiblilty of form elements
     * @param  {object} e jQuery event object
     * @return this
     */
    this.statemanager = function(e) {
      var self = this;
      var $el = $(e.target);
      var state = {
        config: $.extend({}, this.defaultstate, $el.find('option:selected').data()),
        value: $el.val()
      };

      $.each(state.config, function(key, val) {
        self.$el.find(self.stateLookup[key]).toggle(val)
      });
      return this;
    }


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
  }
};
