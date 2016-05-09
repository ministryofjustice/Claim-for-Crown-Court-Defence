moj.Modules.FeeCalculator = {
  el: '#expenses, #basic-fees, #misc-fees, #fixed-fees',

  init: function() {

    this.addChangeEvent();
  },

  calculateAmount: function(rate, quantity) {
    var r = rate || 0;
    var q = quantity || 0;
    q = q < 0 ? 0 : q;
    var t = (r * q).toFixed(2);
    t = t < 0 ? 0 : t;
    return t;

  },
  addChangeEvent: function() {
    var self = this;

    $(this.el).on('cocoon:after-insert', function (e) {
      var $el = $(e.target);
      $el.siblings('.no-dates').hide();
    });

    $(this.el).on('cocoon:after-remove', function (e) {
      var $el = $(e.target);

      if($el.find('.fee-dates').length === 0){
       $el.siblings('.no-dates').show();
      }
    });


    $(this.el).on('change', '.quantity, .rate', function(e) {
      var wrapper = $(e.target).closest('.nested-fields');
      var quantity = parseFloat(wrapper.find('.quantity').val());
      var rate = parseFloat(wrapper.find('.rate').val());
      var total = self.calculateAmount(rate, quantity);
      if (isNaN(total)) {
        wrapper.find('.amount').text(' ');
      } else {
        wrapper.find('.amount').text('£ ' + total);
      }
    });
  },
  totalFee: function() {
    //get all the amount values on the page
    var $allAmounts = $('.amount');
    var arrDirtyAmounts = [];
    var arrCleanAmounts = [];
    var totalAmount = 0;
    var index = 0;

    //For each amount stick it into an array
    $allAmounts.each(function() {
      var $element = $(this);

      if ($element.filter('td').length > 0) {
        arrDirtyAmounts.push($element.text());
      } else {
        arrDirtyAmounts.push($element.val());
      }
    });

    //clean the values
    for (index = 0; index < arrDirtyAmounts.length; index++) {

      var currentVal = parseFloat(arrDirtyAmounts[index].replace(/[^0-9-.]/g, ''));

      if (isNaN(currentVal) === false) {
        arrCleanAmounts.push(currentVal);
      }
    }

    //Sum the value
    for (index = 0; index < arrCleanAmounts.length; index++) {
      totalAmount = totalAmount + arrCleanAmounts[index];
    }

    return totalAmount;
  }
};