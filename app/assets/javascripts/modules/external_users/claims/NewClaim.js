moj.Modules.NewClaim = {
  $expenses : $('#expenses'),

  init : function() {
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

    //Attach Expense type event listeners
    self.attachToExpenseTypes();
    self.attachToExpenseReason();

    //Attach cocoon events to count number of expenses and update labels
    self.setNumberOfExpenses();

    //Show/hide expense elements on page load
    this.$expenses.find('select.js-expense-type').each(function (){
      self.showHideExpenseFields(this);
    });
  },

  attachToOffenceClassSelect : function() {
    $('#offence_class_description').change(function() {
      $('#claim_offence_id').val($(this).val());
    });

    $('#offence_class_description').change();
  },

  attachToExpenseTypes : function() {
    var self = this;
    this.$expenses.on('change', 'select.js-expense-type', function() {
      self.showHideExpenseFields(this);
    });
  },

  showHideExpenseFields : function(elem){
    var $element = $(elem);
    var $currentExpense = $element.closest('.expense-group');
    var dataAttribute = $element.find('option:selected').data();
    var $location = $currentExpense.find('.js-expense-location');
    var $distance = $currentExpense.find('.js-expense-distance');
    var $mileage = $currentExpense.find('.js-expense-mileage');
    var $hours = $currentExpense.find('.js-expense-hours');
    var $reason = $currentExpense.find('.js-expense-reason');
    var $amount = $currentExpense.find('.js-expense-amount');
    var $reasonText = $currentExpense.find('.js-expense-reason-text');

    //hide all the fields by default
    if($element.find('option:selected').is(':first-child')){
      $location
        .add($amount)
        .add($distance)
        .add($mileage)
        .add($mileage)
        .add($hours)
        .add($reason)
        .add($reasonText)
        .hide();
    }else{
      $amount.show();
      $reason.trigger('change').show();

      //show/Hide distance
      $distance.toggle(dataAttribute.distance);

      //show/Hide mileage
      $mileage.toggle(dataAttribute.mileage);

      //show/Hide hours
      $hours.toggle(dataAttribute.hours);

      //show/Hide location
      $location
        .toggle(dataAttribute.location)
        .find('label')
        .text(dataAttribute.locationLabel);

      if(dataAttribute.hours === true) {
        $currentExpense.find('.js-expense-amount').removeClass('first-col');
      }else{
        $currentExpense.find('.js-expense-amount').addClass('first-col');
      }
    }
  },

  attachToExpenseReason : function(){
    var self = this;

    self.$expenses.find('.js-expense-reason').on('change', 'select', function(){
      self.showHideExpenseReasonsText(this);
    });
  },

  showHideExpenseReasonsText : function(elem){
    var $reason = $(elem);
    var $currentExpense = $reason.closest('.expense-group');
    var visible = $reason.find('option:selected').text() === 'Other';

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
