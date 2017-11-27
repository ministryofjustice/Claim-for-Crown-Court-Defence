moj.Modules.NumberInput = {
  el: 'input.rate, input.total, input.quantity',
  arr: ['0','0.00'],
  init : function () {
    var self = this;
    $(this.el).is(function(idx, el){
      if(!!~self.arr.indexOf(this.value)){
        this.value = '';
      }
    });
  }
};
