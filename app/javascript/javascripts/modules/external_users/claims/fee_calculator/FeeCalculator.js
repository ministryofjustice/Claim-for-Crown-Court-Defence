(function(exports, $) {
  var Modules = exports.Modules.FeeCalculator || {};

  // This init is called by the MOJ core js
  Modules.init = function() {
    if(this.UnitPrice){
      this.UnitPrice.init();
    }
    if(this.GraduatedPrice){
      this.GraduatedPrice.init();
    }
  };

  exports.Modules.FeeCalculator = Modules;
}(moj, jQuery));
