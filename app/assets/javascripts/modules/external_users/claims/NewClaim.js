moj.Modules.NewClaim = {
  $expenses : $('#expenses'),
  $element : {},
  $currentExpense : {},
  dataAttribute : {},
  $location : {},
  $distance : {},
  $mileage : {},
  $hours : {},
  $reason : {},
  $amount : {},
  $reasonText : {},
  $ariaLiveRegion : {},

  init : function() {

    //Claim basic section
    this.initBasicClaim();
    //Attach Expense type event listeners
    this.initExpense();
  },

  initBasicClaim : function() {
    var self = this;

    self.$offenceCategorySelect = $('#offence_category_description');

    self.$offenceCategorySelect.change(function() {
      var param = $.param({description : $(this).find(':selected').text()});
      $.getScript('/offences?' + param);
    });

    if(!$('#claim_offence_id').val()) {
      $('.offence-class-select').hide();
      self.$offenceCategorySelect.change();
    }
    else {
      $('#offence_class_description').select2('val', $('#claim_offence_id').val());
    }

    self.attachToOffenceClassSelect();

  },

  initExpense : function() {
    var self = this;
    self.attachEventsForExpenseTypes();
    self.attachToExpenseReason();

    //Attach cocoon events to count number of expenses and update labels
    self.setNumberOfExpenses();

    //Show/hide expense elements on page load
    self.$expenses.find('select.js-expense-type').each(function (){
      self.showHideExpenseFields(this);
    });
  },

  attachToOffenceClassSelect : function() {
    $('#offence_class_description').change(function() {
      $('#claim_offence_id').val($(this).val());
    });

    $('#offence_class_description').change();
  },

  attachEventsForExpenseTypes : function() {
    var self = this;
    this.$expenses.on('change', 'select.js-expense-type', function() {
      self.showHideExpenseFields(this);
    });
  },

  getCurrentExpenseSection : function(elem) {
    this.$element = $(elem);
    this.$currentExpense = this.$element.closest('.expense-group');
    this.dataAttribute = this.$element.find('option:selected').data();
    this.$location = this.$currentExpense.find('.js-expense-location');
    this.$distance = this.$currentExpense.find('.js-expense-distance');
    this.$mileage = this.$currentExpense.find('.js-expense-mileage');
    this.$hours = this.$currentExpense.find('.js-expense-hours');
    this.$reason = this.$currentExpense.find('.js-expense-reason');
    this.$amount = this.$currentExpense.find('.js-expense-amount');
    this.$reasonText = this.$currentExpense.find('.js-expense-reason-text');
    this.$ariaLiveRegion = this.$element.next();
  },

  showHideExpenseFields : function(elem){
    var self = this;

    self.getCurrentExpenseSection(elem);

    //hide all the fields by default
    if(self.$element.find('option:selected').is(':first-child')){
      self.$location
        .add(self.$amount)
        .add(self.$distance)
        .add(self.$mileage)
        .add(self.$mileage)
        .add(self.$hours)
        .add(self.$reason)
        .add(self.$reasonText)
        .hide();
    }else{
      self.showExpenseFields(elem);
    }
  },

  showExpenseFields : function (elem){
    var self = this;
    self.$amount.show();

    self.buildReasonSelectOptions(elem);

    self.$reason.trigger('change').show();

    //show/Hide distance
    self.$distance.toggle(self.dataAttribute.distance);

    //show/Hide mileage
    self.$mileage.toggle(self.dataAttribute.mileage);

    //show/Hide hours
    self.$hours.toggle(self.dataAttribute.hours);

    //show/Hide location
    self.$location
      .toggle(self.dataAttribute.location)
      .find('label')
      .text(self.dataAttribute.locationLabel);

    self.$currentExpense.find('.js-expense-amount').toggleClass('first-col', !self.dataAttribute.hours);

    self.$ariaLiveRegion.children().hide().end().append('<div>Great this works</div>');
  },

  attachToExpenseReason : function() {
    var self = this;

    self.$expenses.on('change', '.js-expense-reason select', function(){
      self.showHideExpenseReasonsText(this);
    });
  },

  buildReasonSelectOptions : function(expenseType) {
    var newReason = [];
    var expenseReason = {};
    var self = this;
    var selectedVAL = parseInt(this.$reason.find('select').find('option:selected').val());

    self.getCurrentExpenseSection(expenseType);

    expenseReason = MOJ.ExpenseReasons[self.dataAttribute.reasonSet];

    for(var opt in expenseReason){
      if(expenseReason.hasOwnProperty(opt)){
        var currentOption = new Option(expenseReason[opt].reason, expenseReason[opt].id);

        currentOption.setAttribute('data-reason-text', expenseReason[opt].reason_text);
        if(expenseReason[opt].id === selectedVAL){
          currentOption.setAttribute('selected', 'selected');
        }

        newReason.push(currentOption);
      }
    }
    self.$reason.find('select').children().remove().end().append(newReason);
  },

  showHideExpenseReasonsText : function(elem){
    var $reason = $(elem);
    var $currentExpense = $reason.closest('.expense-group');
    var visible = $reason.find('option:selected').data('reason-text');

    if (!visible) {
      $currentExpense.find('.js-expense-reason-text input').val('');
    }
    $currentExpense.find('.js-expense-reason-text').toggle(visible);

  },

  setNumberOfExpenses : function() {
    var self = this;

    self.$expenses.on('cocoon:after-insert cocoon:after-remove', function(e, insertedItem){
      $(this).find('.js-expense-count').each(function(i){
        var $element = $(this);
        var $currentExpense = $element.closest('.expense-group');

        $element.text(i + 1);

        $currentExpense.find('.js-expense-remove-count').text(i + 1);
      });

      //if inserting show/hide the new expense fields and set focus
      if (e.type === 'cocoon:after-insert'){
        self.showHideExpenseFields($(insertedItem).find('.js-expense-type'));

        $(insertedItem).find('input:first').focus() ;
      }
    });
  }
};
