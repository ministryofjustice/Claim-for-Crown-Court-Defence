(function(exports, $) {
  var Modules = exports.Modules.FeeCalculator || {};

  // This init is called by the MOJ core js
  Modules.init = function() {

    // A bit rudimentary but here
    // you init the submodules.
    // We might want to look for a data-*="true"
    // to activate it
    //
    if(this.UnitPrice){
      this.UnitPrice.init();
    }
    if(this.GraduatedPrice){
      this.GraduatedPrice.init();
    }
  };

  exports.Modules.FeeCalculator = Modules;
}(moj, jQuery));
