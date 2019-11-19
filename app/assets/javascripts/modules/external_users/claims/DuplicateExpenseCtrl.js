moj.Modules.DuplicateExpenseCtrl = {
  el: '.mod-expenses',
  init: function () {
    this.$el = $(this.el);

    if (this.$el.length) {
      this.bindEvents();
    }
  },

  bindEvents: function () {
    var self = this;

    this.$el.on('click', '.fx-duplicate-expense', function () {
      self.step1();
      // return false to stop the href;
      return false;
    });

    $.subscribe('/step1/complete/', function (e, data) {
      self.step2(data);
    });
  },
  /**
   * Step 1 will scrape the DOM for the
   * models, format it into an object and
   * publish the data for use
   * @return {[type]} [description]
   */
  step1: function () {
    this.mapFormData().then(function (data) {
      $.publish('/step1/complete/', data);
    });
    return this;
  },

  /**
   * Step 2 will click the add button and
   * fill in the models
   * @param  {Object} data Models for the new section
   * @return {[type]}      [description]
   */
  step2: function (data) {
    this.$el.find('.add_fields').click();
    this.populateNewItem(data);
    return this;
  },

  /**
   * Here the new dom nodes are given their
   * values and the change events are fired
   * @param  {Object} data The model for the new section
   */
  populateNewItem: function (data) {
    var $el = $('.expense-group:last');
    // expense type & travel reasons + other & milage rates
    this.setSelectValue($el, '.fx-travel-expense-type select', data.expense_type_id);
    this.setSelectValue($el, '.fx-travel-reason select', data.reason_id, data.location_type);
    this.setSelectValue($el, '.fx-travel-reason-other input', data.reason_text);

    //amounts
    this.setInputValue($el, '.fx-travel-vat-amount input', data.vat_amount);
    this.setInputValue($el, '.fx-travel-net-amount input', data.amount);

    // Hours & distance
    this.setInputValue($el, '.fx-travel-hours', data.hours);
    this.setInputValue($el, '.fx-travel-distance input', data.distance);
    this.setInputValue($el, '.fx-travel-calculated-distance', data.calculated_distance);

    this.setInputValue($el, '.fx-travel-location input', data.location);

    // select the option by the data.location value
    $el.find('.fx-establishment-select select option').filter(function (idx, el) {
      if ($(el).text() == data.location) {
        $(el).prop('selected', true);
        return;
      }
    });

    this.setRadioValue($el, '.fx-travel-mileage input', data.mileage_rate_id);

    // set focus state on '.remove_fields' within the new section
    $el.find('.remove_fields:last').focus();

    // trigger the side bar to recalculate all totals
    $('#claim-form').trigger('recalculate');
  },

  setRadioValue: function ($el, selector, val) {
    if (val) {
      $el.find(selector + '[id$=mileage_rate_id_' + val + ']').prop('checked', true).click();
    }
  },

  setSelectValue: function ($el, selector, val, location_type) {
    if (location_type) {
      $el.find(selector + ' option[data-location-type=' + location_type + ']').prop('selected', true);
      $el.find(selector).trigger('change');
      return;
    }

    if (val) {
      $el.find(selector).val(val).trigger('change');
    }
  },

  setInputValue: function ($el, selector, val) {
    if (val) {
      $el.find(selector).val(val);
    }
  },

  /**
   * Get all the `input` & `select` elements and
   * serialise them into an array
   * @return {Array} Serialised form elements
   */
  getFormData: function () {
    return $('.expense-group:last').find('input,select').serializeArray();
  },

  /**
   * The format of the input is important
   * Here we break up the input name attr
   * and use the last value at the key
   * `<input name="this[is-the][0][modelname]" ../>`
   * @return {String}     the model name
   */
  getKeyName: function (obj) {
    var str;
    if (obj.name.indexOf('][') === -1) {
      return obj.name;
    }
    str = obj.name.split('][').slice(2)[0];
    return str.substring(0, str.length - 1);
  },

  /**
   * Map the serialised data into an obj
   * @return {Object}   Key/Value pairs to
   * populate the duplicated expenses
   */
  mapFormData: function () {
    var deferred = $.Deferred();
    var self = this;
    var data = {};
    $.map(this.getFormData(), function (obj, idx) {
      var str = self.getKeyName(obj);
      if (obj.value) {
        data[str] = obj.value;
      }
    });
    deferred.resolve(data);
    return deferred.promise();
  }
};

(function ($) {
  $.fn.serializeFormJSON = function () {

    var o = {};
    var a = this.serializeArray();
    $.each(a, function () {
      if (o[this.name]) {
        if (!o[this.name].push) {
          o[this.name] = [o[this.name]];
        }
        o[this.name].push(this.value || '');
      } else {
        o[this.name] = this.value || '';
      }
    });
    return o;
  };
})(jQuery);
