moj.Modules.FeeCalculator = {
  el: '#expenses, #basic-fees, #misc-fees, #fixed-fees, #graduated-fees',

  init: function() {
    this.addCocoonHooks();
    this.addChangeEvent();
  },

  calculateAmount: function(rate, quantity) {
    var r = rate || 0;
    var q = isNaN((quantity < 0 ? 0 : quantity)) ? 1 : quantity;
    var t = (r * q).toFixed(2);
    t = t < 0 ? 0 : t;
    return t;
  },

  addCocoonHooks: function() {
    var self = this;
    var $elem = $(this.el);

    $elem.on('cocoon:after-insert', function(e) {
      var $el = $(e.target);
      $el.siblings('.no-dates').hide();
    });

    $elem.on('cocoon:after-remove', function(e) {
      var $el = $(e.target);
      if ($el.find('.fee-dates').length === 0) {
        $el.siblings('.no-dates').show();
      }
      $el.trigger('recalculate');
    });
  },

  addChangeEvent: function() {
    var self = this;

    $(this.el).on('change', '.quantity, .rate', function(e) {
      var wrapper = $(e.target).closest('.nested-fields');
      if(!wrapper.data('muterowcalculation')){
        self.calculateRow(e);
      }
    });

    $(this.el).on('change', '.quantity, .rate, .amount, .vat, .total', function(e) {
      var wrapper = $(e.target).closest('.nested-fields');
      wrapper.trigger('recalculate');
    });
  },

  calculateRow: function(e) {
    var self = this;
    var wrapper = $(e.target).closest('.nested-fields');
    var quantity = parseFloat(wrapper.find('.quantity').val() || 1);
    var rate = parseFloat(wrapper.find('.rate').val());
    var total = self.calculateAmount(rate, quantity);

    if (isNaN(total)) {
      wrapper.find('.total').text('');
    } else {
      wrapper.find('.total').html('&pound; ' + moj.Helpers.SideBar.addCommas(total));
      wrapper.find('.total').data('total', total);
    }
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