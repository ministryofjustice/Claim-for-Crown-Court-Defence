moj.Modules.TravelExpenseCurrent = {
  $expenses: $('#expenses'),

  _init: function() {
    var self = this;
    self.attachEventsForExpenseTypes();
    self.attachToExpenseReason();

    //Attach cocoon events to count number of expenses and update labels
    self.setNumberOfExpenses();

    //Show/hide expense elements on page load
    self.$expenses.find('.fx-travel-expense-type select').each(function() {
      self.showHideExpenseFields(this);
    });
  },

  attachEventsForExpenseTypes: function() {
    // console.log('attachEventsForExpenseTypes');
    var self = this;
    this.$expenses.on('change', '.fx-travel-expense-type select', function() {
      self.showHideExpenseFields(this);
    });
  },

  attachToExpenseReason: function() {
    var self = this;

    self.$expenses.on('change', '.fx-expense-reason select', function() {
      self.showHideExpenseReasonsText(this);
    });
  },

  setNumberOfExpenses: function() {
    // console.log('setNumberOfExpenses');
    var self = this;

    self.$expenses.on('cocoon:after-insert cocoon:after-remove', function(e, insertedItem) {
      $(this).find('.js-expense-count').each(function(i) {
        var $element = $(this);
        var $currentExpense = $element.closest('.expense-group');

        $element.text(i + 1);

        $currentExpense.find('.js-expense-remove-count').text(i + 1);
      });

      //if inserting show/hide the new expense fields and set focus
      if (e.type === 'cocoon:after-insert') {
        self.showHideExpenseFields($(insertedItem).find('.fx-travel-expense-type'));

        $(insertedItem).find('input:first').focus();
      }
    });
  },

  showHideExpenseFields: function(elem) {
    // console.log('showExpenseFields', /*[elem]*/);
    var self = this;

    self.getCurrentExpenseSection(elem);

    //hide all the fields by default
    if (self.$element.find('option:selected').is(':first-child')) {
      self.$location
        .add(self.$amount)
        .add(self.$vat_amount)
        .add(self.$distance)
        .add(self.$mileage)
        .add(self.$hours)
        .add(self.$reason)
        .add(self.$reasonText)
        .add(self.$date)
        .hide();
    } else {
      self.showExpenseFields(elem);
    }

    // Clear unused fields to avoid submitting them and causing validation errors server-side
    self.clearUnusedFields(self.$currentExpense);
  },

  showHideExpenseReasonsText: function(elem) {
    // console.log('showHideExpenseReasonsText', /*[elem]*/);
    var $reason = $(elem);
    var $currentExpense = $reason.closest('.expense-group');
    var visible = $reason.find('option:selected').data('reason-text');

    if (!visible) {
      $currentExpense.find('.fx-expense-reason-text input').val('');
    }
    $currentExpense.find('.fx-expense-reason-text').toggle(visible);

  },

  getCurrentExpenseSection: function(elem) {
    // console.log('getCurrentExpenseSection', [elem]);
    this.$element = $(elem);
    this.$currentExpense = this.$element.closest('.expense-group');
    this.dataAttribute = this.$element.find('option:selected').data();
    this.$location = this.$currentExpense.find('.js-expense-location');
    this.$distance = this.$currentExpense.find('.js-expense-distance');
    this.$mileage = this.$currentExpense.find('.js-expense-mileage');
    this.$mileage_car = this.$currentExpense.find('.fx-travel-expense-type-car');
    this.$mileage_bike = this.$currentExpense.find('.fx-travel-expense-type-bike');
    this.$hours = this.$currentExpense.find('.js-expense-hours');
    this.$reason = this.$currentExpense.find('.fx-expense-reason');
    this.$amount = this.$currentExpense.find('.js-expense-amount');
    this.$vat_amount = this.$currentExpense.find('.js-expense-vat-amount');
    this.$reasonText = this.$currentExpense.find('.fx-expense-reason-text');
    this.$date = this.$currentExpense.find('.js-expense-date');
    this.$ariaLiveRegion = this.$element.next();
  },

  showExpenseFields: function(elem) {
    // console.log('showExpenseFields', /*[elem]*/);
    var self = this;

    self.$date.show();

    self.$amount.show();

    self.$vat_amount.show();

    self.buildReasonSelectOptions(elem);

    self.$reason.trigger('change').show();

    //show/Hide distance
    self.$distance.toggle(self.dataAttribute.distance);

    //show/Hide mileage
    self.$mileage.toggle(self.dataAttribute.mileage);

    self.toggleMileageRateFields();

    //show/Hide hours
    self.$hours.toggle(self.dataAttribute.hours);

    //show/Hide location
    self.$location
      .toggle(self.dataAttribute.location)
      .find('label')
      .text(self.dataAttribute.locationLabel);

    self.$currentExpense.find('.js-expense-amount').toggleClass('first-col', !self.dataAttribute.hours);

    self.$ariaLiveRegion.children().hide().end();
  },

  buildReasonSelectOptions: function(expenseType) {
    // console.log('buildReasonSelectOptions', expenseType);
    var newReason = [];
    var expenseReason = {};
    var self = this;
    var selectedVAL = parseInt(this.$reason.find('select').find('option:selected').val());

    self.getCurrentExpenseSection(expenseType);

    expenseReason = MOJ.ExpenseReasons[self.dataAttribute.reasonSet];

    for (var opt in expenseReason) {
      if (expenseReason.hasOwnProperty(opt)) {
        var currentOption = new Option(expenseReason[opt].reason, expenseReason[opt].id);

        currentOption.setAttribute('data-reason-text', expenseReason[opt].reason_text);
        if (expenseReason[opt].id === selectedVAL) {
          currentOption.setAttribute('selected', 'selected');
        }

        newReason.push(currentOption);
      }
    }
    self.$reason.find('select').children().remove().end().append(newReason);
  },

  toggleMileageRateFields: function() {
    // console.log('toggleMileageRateFields');
    var self = this;
    // toggle between bike / car mileage
    if (self.dataAttribute.mileageType === 'bike') {
      self.$mileage_car.toggle(false);
      self.$mileage_bike.toggle(true);
      $(self.$mileage_bike).find('input').prop('disabled', false).prop('checked', 'checked').trigger('click');
    } else {
      self.$mileage_car.toggle(true);
      self.$mileage_bike.toggle(false);
      $(self.$mileage_bike).find('input').prop('disabled', true).prop('checked', false);;
    }
  },
  clearUnusedFields: function(elem) {
    // console.log('clearUnusedFields' /*, elem*/);
    elem.find('input:hidden').not('input[type="hidden"]').not('input[type="radio"]').val('');
    elem.find('select:hidden').not('select[type="hidden"]').val('');
    elem.find('input:hidden[type="radio"]').prop("checked", false);
  }
}
