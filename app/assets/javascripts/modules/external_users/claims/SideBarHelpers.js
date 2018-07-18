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
      return parseFloat(this.$el.find(selector + ':visible').val()) || 0;
    };

    this.getDataVal = function(selector) {
      return parseFloat(this.$el.find('.' + selector).data('total')) || false;
    };

    this.getMultipliedVal = function(val1, val2) {
      return parseFloat((this.getVal(val1) * this.getVal(val2)).toFixed(2));
    }
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
      // TODO: Can this be removed? Investigate across block types.
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
      return this;
    };

    this.setTotals = function() {
      this.totals = {
        quantity: this.getVal('.quantity'),
        rate: this.getVal('.rate'),
        amount: this.getVal('.amount'),
        total: this.getMultipliedVal('.quantity', '.rate'),
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
      return this;
    }
  },
  ExpenseBlock: function() {
    var self = this;
    var staticdata = moj.Helpers.SideBar.staticdata.expenseBlock;
    moj.Helpers.SideBar.FeeBlock.apply(this, arguments);

    this.stateLookup = staticdata.stateLookup;
    this.defaultstate = staticdata.defaultstate;
    this.expenseReasons = staticdata.expenseReasons;

    this.init = function() {
      this.config.fn = 'ExpenseBlock';

      // Overides for LGFS reason set C;
      // NOT REQUIRED IN THE DESIGN UPGRADE
      // this.config.featureDistance = $('#expenses').data('featureDistance');
      //
      // Bind events
      this.bindEvents();
      // Load the state based on the selected option
      this.loadCurrentState();
      return this;
    };
    this.bindEvents = function() {
      // Bind the core change listner
      this.bindRecalculate();

      // Bind events on the this.$el element
      this.bindListners();
    };
    // Bind delegated events onto this.$el
    this.bindListners = function() {
      var self = this;
      /**
       * Listen for the `expense type` change event and
       * pass the event object to the statemanager
       */
      this.$el.on('change', '.fx-travel-expense-type select', function(e) {
        self.statemanager(e);
      });
      /**
       * Travel reason change event
       * - extract the `other reason` input state var and call toggle on it
       * - set the hidden `location_type` to the selected val
       *   this is used to reset to the correct line in the select box
       *   when the user returns to the page
       */
      this.$el.on('change', '.fx-travel-reason select', function(e) {
        var $option, state, location_type;

        $option = $(e.target).find('option:selected');
        state = $option.data('reasonText');
        location_type = $option.data('locationType') || '';
        self.$el.find('.fx-location-type').val(location_type)
        self.$el.find('.fx-travel-reason-other').css('display', state ? 'block' : 'none');
      });
      return this;
    };
    this.loadCurrentState = function() {
      var $select = this.$el.find('.fx-travel-expense-type select');
      if ($select.val()) {
        $select.trigger('change');
      }
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
      var reasons = [];
      var $el = $(e.target);
      var state = {
        config: $.extend({}, this.defaultstate, $el.find('option:selected').data()),
        value: $el.val()
      };
      var $parent = $el.closest('.js-block');
      var $detached = $parent.find('.form-section-compound').detach();
      var locationType = $detached.find('.fx-location-type').val();
      var travelReasonValue = $detached.find('.fx-travel-reason option:selected').val();
      // regular fields
      ['date',
        'distance',
        'hours',
        'mileage',
        'reason',
        'vatAmount'
      ].forEach(function(value, idx) {
        $detached.find(self.stateLookup[value]).css('display', (state.config[value] ? 'block' : 'none'));
      });
      // net amount & lable
      $detached.find(this.stateLookup['netAmount']).css('display', (state.config['date'] ? 'block' : 'none'));
      $detached.find(this.stateLookup['netAmount'] + ' label').text(state.config['netAmountLabel']);
      // location & lable
      $detached.find(this.stateLookup['location']).css('display', (state.config['date'] ? 'block' : 'none'));
      $detached.find(this.stateLookup['location'] + ' label').text(state.config['locationLabel']);

      // Overides for LGFS reason set C;
      // NOT REQUIRED IN THE DESIGN UPGRADE
      // state.config.reasonSet = (this.config.featureDistance ? 'C' : (state.config.reasonSet || 'A'));

      // travel reasons
      reasons.push(new Option('Please select'));
      this.expenseReasons[state.config.reasonSet].forEach(function(obj) {
        $option = $(new Option(obj.reason, obj.id));
        $option.attr('data-reason-text', obj.reason_text)
        $option.attr('data-location-type', obj.location_type)
        if (locationType) {
          if (obj.location_type == locationType && obj.id == travelReasonValue) {
            $option.prop('selected', true);
          }
        } else {
          if (obj.id == travelReasonValue) {
            $option.prop('selected', true);
          }
        }
        reasons.push($option)
      });
      // Attach the travel reasons
      $detached.find('.fx-travel-reason select').children().remove().end().append(reasons);
      // Mileage radios: BIKE
      if (state.config.mileageType === 'bike') {
        // Display the correct block
        $detached.find('.fx-travel-mileage-car').css('display', 'none');
        $detached.find('.fx-travel-mileage-bike').css('display', 'block');
        // Activate the radios for this block and reset checked status
        $detached.find('.fx-travel-mileage-bike input[type=radio]').is(function() {
          $(this).prop('checked', true).prop('disabled', false);
        });
        // Deactivate the others and reset checked status
        $detached.find('.fx-travel-mileage-car input').is(function() {
          $(this).prop('checked', false).prop('disabled', true);
        });
      }
      // Mileage radios: BIKE
      if (state.config.mileageType === 'car') {
        // Display the correct block
        $detached.find('.fx-travel-mileage-car').css('display', 'block');
        $detached.find('.fx-travel-mileage-bike').css('display', 'none');
        // Activate the radios for this block and reset checked status
        $detached.find('.fx-travel-mileage-car input').is(function() {
          $(this).prop('disabled', false);
        });
        // Deactivate the others and reset checked status
        $detached.find('.fx-travel-mileage-bike input').is(function() {
          $(this).prop('checked', false).prop('disabled', true);
        });
      }
      return $parent.append($detached);
    };
  },
  staticdata: {
    expenseBlock: {
      stateLookup: {
        "vatAmount": ".fx-travel-vat-amount",
        "reason": ".fx-travel-reason",
        "netAmount": ".fx-travel-net-amount",
        "location": ".fx-travel-location",
        "hours": ".fx-travel-hours",
        "distance": ".fx-travel-distance",
        "destination": ".fx-travel-destination",
        "date": ".fx-travel-date",
        "mileage": ".fx-travel-mileage",
        "grossAmount": ".fx-travel-gross-amount"
      },
      defaultstate: {
        "mileage": false,
        "date": false,
        "distance": false,
        "grossAmount": false,
        "hours": false,
        "location": false,
        "netAmount": false,
        "reason": false,
        "vatAmount": false,
      },
      expenseReasons: {
        "A": [{
          "id": 1,
          "reason": "Court hearing",
          "reason_text": false
        }, {
          "id": 2,
          "reason": "Pre-trial conference expert witnesses",
          "reason_text": false
        }, {
          "id": 3,
          "reason": "Pre-trial conference defendant",
          "reason_text": false
        }, {
          "id": 4,
          "reason": "View of crime scene",
          "reason_text": false
        }, {
          "id": 5,
          "reason": "Other",
          "reason_text": true
        }],
        "B": [{
          "id": 2,
          "reason": "Pre-trial conference expert witnesses",
          "reason_text": false
        }, {
          "id": 3,
          "reason": "Pre-trial conference defendant",
          "reason_text": false
        }, {
          "id": 4,
          "reason": "View of crime scene",
          "reason_text": false
        }]
      }
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
