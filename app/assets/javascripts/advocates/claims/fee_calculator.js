"use strict";

var adp = adp || {};

adp.feeCalculator = {
  init : function(container_id) {
    this.addChangeEvent(container_id);
  },
  calculateAmount: function(rate, quantity, modifier) {

    var r = rate || 0;
    var q = (quantity || 0) + (modifier || 0);
    q = q < 0 ? 0 : q;
    var t = (r * q).toFixed(2);
    t = t < 0 ? 0 : t;
    return t;

  },
  addChangeEvent: function(container_id) {
    $('#' + container_id).on('change', '.quantity, .rate', function(e) {

      var wrapper  = $(e.target).closest('.nested-fields');
      var quantity = parseFloat(wrapper.find('.quantity').val());
      var modifier = parseFloat(wrapper.find('.quantity-modifier').text());
      var rate     = parseFloat(wrapper.find('.rate').val());
      var total = adp.feeCalculator.calculateAmount(rate,quantity,modifier);
      if (isNaN(total) ){
        wrapper.find('.amount').text(' ');
      }
      else{
        wrapper.find('.amount').text('£ '+ total);
      }
    });
  },
  totalFee: function(){
    //get all the amount values on the page
    var $allAmounts = $('.amount'),
    //Array of cash amounts as the user inputted
    arrDirtyAmounts =[],
    arrCleanAmounts = [],
    totalAmount = 0,
    index = 0;

    //For each amount stick it into an array
    $allAmounts.each(function(){
      var $element =$(this);

      if($element.filter('td').length > 0){
        arrDirtyAmounts.push($element.text());
      }else{
        arrDirtyAmounts.push($element.val());
      }
    });

    //clean the values
    for(index = 0; index < arrDirtyAmounts.length; index++){

      var currentVal = parseFloat(arrDirtyAmounts[index].replace(/[^0-9-.]/g, ''));

      if(isNaN(currentVal) === false){
        arrCleanAmounts.push(currentVal);
      }
    }

    //Sum the value
    for(index = 0; index < arrCleanAmounts.length; index++){
      totalAmount = totalAmount + arrCleanAmounts[index];
    }

    return totalAmount;
  }
};
