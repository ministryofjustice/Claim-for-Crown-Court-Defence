$(document).ready( function() {
  (function(){
    'use strict';

    for (var x in moj.Modules.FeeCalculator) {
      if (typeof moj.Modules.FeeCalculator[x].init === 'function') {
        moj.Modules.FeeCalculator[x].init();
      }
    }
  }());
});
