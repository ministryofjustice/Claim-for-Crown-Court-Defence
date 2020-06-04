moj.Helpers.Blocks = {
  Base: function (options) {
    var _options = {
      type: '_Base',
      vatfactor: 0.2,
      mileageFactor: 0.45,
      autoVAT: false,
      metersPerMile: 1609.34
    };
    this.config = $.extend({}, _options, options);
    this.$el = this.config.$el;
    this.el = this.config.el;

    this.setState = function (selector, state) {
      if (this.$el.find(selector).length) {
        if (this.$el.find(selector).is(':visible') === state) {
          return;
        }
        return this.$el.find(selector).css('display', state ? 'block' : 'none');
      }
      throw new Error('Selector did not return an element: ' + selector);
    };

    this.setVal = function (selector, val) {
      if (this.$el.find(selector).length) {
        this.$el.find(selector).val(val).change();
        return;
      }
      throw new Error('Selector did not return an element: ' + selector);
    };

    this.setNumber = function (selector, val, points) {
      points = points || '2';
      if (this.$el.find(selector).length) {
        this.$el.find(selector).val(parseFloat(val).toFixed(points)).change();
        return;
      }
      return;
    };

    this.getConfig = function (key) {
      return this.config[key] || undefined;
    };

    this.updateTotals = function () {
      return 'This method needs an override';
    };

    this.isVisible = function () {
      return this.$el.find('.rate').is(':visible') || this.$el.find('.amount').is(':visible') || this.$el.find('.total').is(':visible');
    };

    this.applyVat = function () {
      if (this.config.autoVAT) {
        this.totals.vat = this.totals.total * this.config.vatfactor;
      }
    };

    this.getVal = function (selector) {
      return parseFloat(this.$el.find(selector + ':visible').val()) || 0;
    };

    this.getDataVal = function (selector, key) {
      return parseFloat(this.$el.find(selector).data(key)) || false;
    };

    this.getMultipliedVal = function (val1, val2) {
      return parseFloat((this.getVal(val1) * this.getVal(val2)).toFixed(2));
    };
  },
  FeeBlock: function () {
    var self = this;
    // copy methods over
    moj.Helpers.Blocks.Base.apply(this, arguments);
    this.totals = {
      quantity: 0,
      rate: 0,
      amount: 0,
      total: 0,
      vat: 0
    };

    this.init = function () {
      this.config.fn = 'FeeBlock';
      this.bindEvents();
      return this;
    };

    this.bindEvents = function () {
      this.bindRecalculate();
    };

    this.bindRecalculate = function () {
      this.$el.on('change keyup', '.quantity, .rate, .amount, .vat, .total', function (e) {
        self.$el.trigger('recalculate');
      });
    };

    this.reload = function () {
      this.updateTotals();
      this.applyVat();
      return this;
    };

    this.setTotals = function () {
      this.totals = {
        quantity: this.getVal('.quantity'),
        rate: this.getVal('.rate'),
        amount: this.getVal('.amount'),
        total: this.getDataVal('.total', 'total') || this.getVal('.total'),
        vat: this.getVal('.vat')
      };

      this.totals.typeTotal = this.totals.total;
      return this.totals;
    };

    this.updateTotals = function (a) {
      if (!this.isVisible()) {
        return this.totals;
      }
      return this.setTotals();
    };

    this.render = function () {
      this.$el.find('.total').html('&pound;' + moj.Helpers.Blocks.addCommas(this.totals.total.toFixed(2)));
      this.$el.find('.total').data('total', this.totals.total);
    };
  },
  FeeBlockCalculator: function () {
    var self = this;
    moj.Helpers.Blocks.FeeBlock.apply(this, arguments);

    this.init = function () {
      this.config.fn = 'FeeBlockCalculator';
      this.bindRecalculate();
      this.bindRender();
      return this;
    };

    this.setTotals = function () {
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

    this.bindRender = function () {
      this.$el.on('change keyup', '.quantity, .rate', function () {
        self.updateTotals();
        self.render();
      });
    };
  },
  FeeBlockManualAmounts: function () {
    var self = this;
    moj.Helpers.Blocks.FeeBlock.apply(this, arguments);

    this.init = function () {
      this.config.fn = 'FeeBlockManualAmounts';

      this.bindRecalculate();
      this.bindRender();
      this.setTotals();
      return this;
    };

    this.setTotals = function () {
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

    this.bindRender = function () {
      this.$el.on('change keyup', '.amount, .vat', function () {
        self.updateTotals();
        self.render();
      });
    };
  },
  PhantomBlock: function () {
    var self = this;
    moj.Helpers.Blocks.Base.apply(this, arguments);
    this.totals = {
      quantity: 0,
      rate: 0,
      amount: 0,
      total: 0,
      vat: 0
    };

    this.isVisible = function () {
      return true;
    };

    this.reload = function () {
      this.totals.total = (parseFloat(this.$el.data('seed')) || 0);
      this.totals.typeTotal = this.totals.total;

      if (this.config.autoVAT) {
        this.totals.vat = this.totals.total * 0.2;
      } else {
        this.totals.vat = (parseFloat(this.$el.data('seed-vat')) || 0);
      }
      return this;
    };

    this.init = function () {
      return this;
    };
  },
  /**
   * ExpenseBlock Class
   * - manage visibility of elements for each expense type
   * - expense type options has data attr that are read
   * - <option data-example="true" data-... />
   * - manage the travel reason select
   * - manage the location select
   */
  ExpenseBlock: function () {
    var self = this;
    var staticdata = moj.Helpers.Blocks.staticdata.expenseBlock;

    moj.Helpers.Blocks.FeeBlock.apply(this, arguments);

    this.stateLookup = staticdata.stateLookup;
    this.defaultstate = staticdata.defaultstate;
    this.expenseReasons = staticdata.expenseReasons;

    this.init = function () {
      this.config.fn = 'ExpenseBlock';
      this.config.featureDistance = $('#expenses').data('featureDistance');

      // Bind events
      this.bindEvents();
      // Load the state based on the selected option
      this.loadCurrentState();
      return this;
    };

    this.bindEvents = function () {
      // Bind the core change listener
      this.bindRecalculate();
      // Bind events on the this.$el element
      this.bindListners();
    };

    this.bindListners = function () {
      var self = this;

      /**
       * Listen for the `expense type` change event and
       * pass the event object to the statemanager
       */
      this.$el.on('change', '.fx-travel-expense-type select', function (e) {
        e.stopPropagation();
        var $el = $(e.target);

        // The lookup is `distance` specific and the
        // feature is toggled as required
        self.distanceLookupEnabled = $el.find('option:selected').data('distance') || false;

        self.statemanager($el);
      });
      /**
       * Travel reason change event
       * - extract the `other reason` input state var and call toggle on it
       * - set the hidden `location_type` to the selected val
       *   this is used to reset to the correct line in the select box
       *   when the user returns to the page
       */
      this.$el.on('change', '.fx-travel-reason select', function (e) {
        e.stopPropagation();

        var $option, state, location_type;

        // cache referance to selected option
        $option = $(e.target).find('option:selected');

        // read  & set `reasonText` state
        reasonTextState = $option.data('reasonText');
        self.setState('.fx-travel-reason-other', reasonTextState);

        // read & set `locationType` value
        location_type = $option.data('locationType') || '';
        self.setVal('.fx-location-type', location_type);

        // create the location `input / select` element
        self.setLocationElement($option.data());
      });

      // Where the location is using a select box, the selected
      // value is stored in a hidden field
      // This is used to reset the correct block state and seleted values
      // when the page reloads
      // The change event will also trigger the distance lookup if required
      this.$el.on('change', '.fx-establishment-select select', function (e) {
        e.stopPropagation();
        var $option = $(e.target).find('option:selected');

        self.$el.find('.fx-location-model').val($option.text());

        if (self.distanceLookupEnabled) {
          self.getDistance({
            claimid: $('#claim-form').data('claimId'),
            destination: $option.data('postcode')
          }).then(function (number, result) {
            self.updateMileageElements(number, false, result);
          }, function (error) {
            self.viewErrorHandler(error);
          });
        }
      });

      // Binding to the mileage radio buttons (click and change)
      // to update calculations
      this.$el.on('change, click', '.fx-travel-mileage input[type=radio]', function (e) {
        self.updateMileageElements(self.getRateId(), true);
      });

      // Binding to mileage input key up
      // when a user manually enters the distance to update the calculations
      this.$el.on('keyup', '.fx-travel-distance input', function (e) {
        var rateId = self.getRateId();
        self.updateMileageElements(rateId, rateId ? true : false);
      });

      // Binding to the net amount key up to update the VAT amount field
      this.$el.on('keyup', '.fx-travel-net-amount input', function (e) {
        self.setNumber('.fx-travel-vat-amount input', e.target.value * self.config.vatfactor);
      });

      return this;
    };

    this.getRateId = function () {
      return this.$el.find('.fx-travel-mileage input[type=radio]:visible:checked').val();
    };

    this.updateMileageElements = function (rateId, calculate, result) {
      var factor = (rateId == '3') ? 0.20 : (rateId == '1') ? 0.25 : this.config.mileageFactor;
      if (!result) {
        result = {
          miles: self.$el.find('.fx-travel-distance input').val()
        };
      }
      self.setNumber('.fx-travel-distance input', result.miles, '0');

      if (calculate || self.$el.find('.fx-travel-mileage input[type=radio]:visible:checked').length) {
        self.setNumber('.fx-travel-net-amount input', result.miles * factor);
        self.setNumber('.fx-travel-vat-amount input', (result.miles * factor) * self.config.vatfactor);
      }
    };

    // Call the Distance helper and return the
    // id for the checked ra
    this.getDistance = function (ajaxConfig) {
      var def = $.Deferred();
      var self = this;
      moj.Helpers.API.Distance.query(ajaxConfig).then(function (result) {
        var number = self.$el.find('.fx-travel-mileage input[type=radio]:visible:checked').val();

        result.miles = Math.round((result.distance / self.config.metersPerMile));
        self.$el.find('.fx-travel-calculated-distance').val(result.miles);

        def.resolve(number, result);

      }, function (result) {
        def.reject(result.error);
      });
      return def.promise();
    };

    // Setting the view error state and message
    this.viewErrorHandler = function (message) {
      var el = this.$el.find('.fx-general-errors');
      el.find('span').text(message);
      el.css('display', 'inline-block');
    };

    // The location elment is an input or a select
    // This method will return the html to append to the dom
    this.setLocationElement = function (obj) {
      if (!obj) throw new Error('Missing param: obj, cannot build element');

      // cache selected value
      var selectedValue = this.$el.find('.fx-location-model').val();

      // If a locationType is present render the select
      // This will set the selected value if present
      // <option data-location-type="crown_court|prison|etc" />
      if (obj.locationType) {
        this.attachSelectWithOptions(obj.locationType, selectedValue);
        return this;
      }

      // Attach input as default / fallback
      return this.displayLocationInput();
    };

    // Display the input and hide the select
    this.displayLocationInput = function () {
      this.$el.find('.location_wrapper').css('display', 'block');
      this.$el.find('.fx-establishment-select').css('display', 'none');
      return this;
    };

    this.attachSelectWithOptions = function (locationType, selectedValue) {
      var self = this;
      var $detachedSelect;

      if (!locationType) throw new Error('Missing param: locationType');

      moj.Helpers.API.Establishments.getAsSelectWithOptions(locationType, {
        prop: 'name',
        value: selectedValue
      }).then(function (els) {

        $detachedSelect = self.$el.find('.fx-establishment-select select').detach();

        $detachedSelect.find('option').remove();
        $detachedSelect.append(els.join(''));

        self.$el.find('.fx-establishment-select').css('display', 'block');
        self.$el.find('.fx-establishment-select').append($detachedSelect);

        // this class `location_wrapper` is added by the adp_text_field ruby helper
        self.$el.find('.location_wrapper').css('display', 'none');
        self.$el.find('.fx-travel-location .has-select label').text(staticdata.locationLabel[locationType] || staticdata.locationLabel.default);

      }, function () {
        throw new Error('Attach options failed:', arguments);
      });
    };

    this.loadCurrentState = function () {
      var $select = this.$el.find('.fx-travel-expense-type select');
      if ($select.val()) {
        $select.trigger('change');
      }
    };

    this.setTotals = function () {
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
    this.statemanager = function ($el) {
      var self = this;
      var reasons = [];
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
      ].forEach(function (value, idx) {
        $detached.find(self.stateLookup[value]).css('display', (state.config[value] ? 'block' : 'none'));

        // Clear out the value for this input
        if (!state.config[value]) {
          $detached.find(self.stateLookup[value] + ' input:not([type=radio])').val('');
        }
      });

      // net amount
      $detached.find(this.stateLookup.netAmount).css('display', (state.config.netAmount ? 'block' : 'none'));

      // location
      $detached.find(this.stateLookup.location).css('display', (state.config.location ? 'block' : 'none'));

      // remove the location data from the form
      if (!state.config.location) {
        $detached.find('.fx-location-model').val('');
        $detached.find('.fx-travel-location > .location_wrapper:first input').val('');
        $detached.find('.fx-travel-location > .fx-establishment-select select').prop('selectedIndex', 0);
      }

      if (this.config.featureDistance) {
        $detached.find(this.stateLookup.location + ' .has-select label').contents().first()[0].textContent = state.config.locationLabel;
      }

      // cache the location input
      if (!this.$location) {
        this.$location = {
          input: $detached.find('.fx-travel-location > .location_wrapper:first'),
          select: $detached.find('.fx-travel-location > .fx-establishment-select')
        };
      }

      // Overides for LGFS reason set C;
      state.config.reasonSet = (this.config.featureDistance ? 'C' : (state.config.reasonSet || 'A'));

      // travel reasons
      reasons.push(new Option('Please select'));

      // Looping over the correct reasonset and
      // build the `<options data-attr="" .. />` elements
      // This will handled the selected option as well
      this.expenseReasons[state.config.reasonSet].forEach(function (obj) {
        $option = $(new Option(obj.reason, obj.id));
        $option.attr('data-reason-text', obj.reason_text);
        $option.attr('data-location-type', obj.location_type);

        // If `locationType` is present then a compounded condition is required
        if (locationType) {
          if (obj.location_type == locationType && obj.id == travelReasonValue) {
            $option.prop('selected', true);
          }
        } else {
          if (obj.id == travelReasonValue) {
            $option.prop('selected', true);
          }
        }
        reasons.push($option);
      });

      // Attach the travel reasons
      $detached.find('.fx-travel-reason select').children().remove().end().append(reasons);

      // Loading the dynamic `location` data
      // wait for the data is loaded before
      // firing the change event
      $.subscribe('/API/establishments/loaded/', function () {
        $detached.find('.fx-travel-reason select').trigger('change');
      });

      $detached = this.radioStateManager($detached, state);

      return $parent.append($detached);
    };

    /**
     * radioStateManager
     * @param $dom  Expense block dom referance
     * @param state State config object
     * @return $dom return the $dom referance
     */
    this.radioStateManager = function ($dom, state) {

      // Clearing the radio buttons if they are not required
      if (!state.config.mileage) {
        $dom.find('.fx-travel-mileage input[type=radio]').is(function () {
          $(this).removeAttr('checked').prop('disabled', true);
        });
        return $dom;
      }

      // Mileage radios: BIKE
      if (state.config.mileageType === 'bike') {
        this.config.mileageFactor = 0.20;
        return this.setRadioState($dom, {
          car: 'none',
          carModel: false,
          bike: 'block',
          bikeModel: true
        });
      }

      // Mileage radios: BIKE
      if (state.config.mileageType === 'car') {
        this.config.mileageFactor = 0.45;
        return this.setRadioState($dom, {
          car: 'block',
          carModel: true,
          bike: 'none',
          bikeModel: false
        });
      }
      return $dom;
    };

    this.setRadioState = function ($dom, config) {
      // Car mileage visibility, radio checked & disabled values
      $dom.find('.fx-travel-mileage-car').css('display', config.car);
      $dom.find('.fx-travel-mileage-car input').is(function () {
        $(this).prop('disabled', !config.carModel);

      });

      // Bike mileage visibility, radio checked & disabled values
      $dom.find('.fx-travel-mileage-bike').css('display', config.bike);
      $dom.find('.fx-travel-mileage-bike input[type=radio]').is(function () {
        $(this).prop('checked', config.bikeModel).prop('disabled', !config.bikeModel).change();
      });
      return $dom;
    };
  },

  staticdata: {
    expenseBlock: {
      stateLookup: {
        'vatAmount': '.fx-travel-vat-amount',
        'reason': '.fx-travel-reason',
        'netAmount': '.fx-travel-net-amount',
        'location': '.fx-travel-location',
        'hours': '.fx-travel-hours',
        'distance': '.fx-travel-distance',
        'destination': '.fx-travel-destination',
        'date': '.fx-travel-date',
        'mileage': '.fx-travel-mileage',
        'grossAmount': '.fx-travel-gross-amount'
      },
      defaultstate: {
        'mileage': false,
        'date': false,
        'distance': false,
        'grossAmount': false,
        'hours': false,
        'location': false,
        'netAmount': false,
        'reason': false,
        'vatAmount': false,
      },
      locationLabel: {
        crown_court: 'Crown court',
        magistrates_court: 'Magistrates\' court',
        prison: 'Prison',
        hospital: 'Hospital',
        default: 'Destination'
      },
      expenseReasons: {
        'A': [{
          'id': 1,
          'reason': 'Court hearing',
          'reason_text': false
        }, {
          'id': 2,
          'reason': 'Pre-trial conference expert witnesses',
          'reason_text': false
        }, {
          'id': 3,
          'reason': 'Pre-trial conference defendant',
          'reason_text': false
        }, {
          'id': 4,
          'reason': 'View of crime scene',
          'reason_text': false
        }, {
          'id': 5,
          'reason': 'Other',
          'reason_text': true
        }],
        'B': [{
          'id': 2,
          'reason': 'Pre-trial conference expert witnesses',
          'reason_text': false
        }, {
          'id': 3,
          'reason': 'Pre-trial conference defendant',
          'reason_text': false
        }, {
          'id': 4,
          'reason': 'View of crime scene',
          'reason_text': false
        }],
        'C': [{
          'id': 1,
          'reason': 'Court hearing (Crown court)',
          'location_type': 'crown_court',
          'reason_text': false
        }, {
          'id': 1,
          'reason': 'Court hearing (Magistrates\' court)',
          'location_type': 'magistrates_court',
          'reason_text': false
        }, {
          'id': 2,
          'reason': 'Pre-trial conference expert witnesses',
          'reason_text': false
        }, {
          'id': 3,
          'reason': 'Pre-trial conference defendant (prison)',
          'location_type': 'prison',
          'reason_text': false
        }, {
          'id': 3,
          'reason': 'Pre-trial conference defendant (hospital)',
          'location_type': 'hospital',
          'reason_text': false
        }, {
          'id': 3,
          'reason': 'Pre-trial conference defendant (other)',
          'reason_text': false
        }, {
          'id': 4,
          'reason': 'View of crime scene',
          'reason_text': false
        }, {
          'id': 5,
          'reason': 'Other',
          'reason_text': true
        }]
      }
    }
  },
  addCommas: function (nStr) {
    nStr += '';
    var x = nStr.split('.');
    var x1 = x[0];
    var x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
      x1 = x1.replace(rgx, '$1' + ',' + '$2');
    }
    return x1 + x2;
  }
};
