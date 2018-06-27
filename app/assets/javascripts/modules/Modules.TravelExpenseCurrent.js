moj.Modules.TravelExpenseCurrent = {
  $expenses: $('#expenses'),

  init: function() {
    var self = this;
    self.attachEventsForExpenseTypes();
    self.attachToExpenseReason();

    //Attach cocoon events to count number of expenses and update labels
    self.setNumberOfExpenses();

    //Show/hide expense elements on page load
    self.$expenses.find('select.js-expense-type').each(function() {
      self.showHideExpenseFields(this);
    });
  },

  attachEventsForExpenseTypes: function() {
    var self = this;
    this.$expenses.on('change', 'select.js-expense-type', function() {
      self.showHideExpenseFields(this);
    });
  },

  attachToExpenseReason: function() {
    var self = this;

    self.$expenses.on('change', '.js-expense-reason select', function() {
      self.showHideExpenseReasonsText(this);
    });
  },

  setNumberOfExpenses: function() {
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
        self.showHideExpenseFields($(insertedItem).find('.js-expense-type'));

        $(insertedItem).find('input:first').focus();
      }
    });
  },

  showHideExpenseFields: function(elem) {
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
    var $reason = $(elem);
    var $currentExpense = $reason.closest('.expense-group');
    var visible = $reason.find('option:selected').data('reason-text');

    if (!visible) {
      $currentExpense.find('.js-expense-reason-text input').val('');
    }
    $currentExpense.find('.js-expense-reason-text').toggle(visible);

  },

  getCurrentExpenseSection: function(elem) {
    this.$element = $(elem);
    this.$currentExpense = this.$element.closest('.expense-group');
    this.dataAttribute = this.$element.find('option:selected').data();
    this.$location = this.$currentExpense.find('.js-expense-location');
    this.$distance = this.$currentExpense.find('.js-expense-distance');
    this.$mileage = this.$currentExpense.find('.js-expense-mileage');
    this.$mileage_car = this.$currentExpense.find('.js-expense-type-car');
    this.$mileage_bike = this.$currentExpense.find('.js-expense-type-bike');
    this.$hours = this.$currentExpense.find('.js-expense-hours');
    this.$reason = this.$currentExpense.find('.js-expense-reason');
    this.$amount = this.$currentExpense.find('.js-expense-amount');
    this.$vat_amount = this.$currentExpense.find('.js-expense-vat-amount');
    this.$reasonText = this.$currentExpense.find('.js-expense-reason-text');
    this.$date = this.$currentExpense.find('.js-expense-date');
    this.$ariaLiveRegion = this.$element.next();
  },

  showExpenseFields: function(elem) {
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
  clearUnusedFields: function(expenseGroup) {
    expenseGroup.find('input:hidden').not('input[type="hidden"]').not('input[type="radio"]').val('');
    expenseGroup.find('select:hidden').not('select[type="hidden"]').val('');
    expenseGroup.find('input:hidden[type="radio"]').prop("checked", false);
  }
}
