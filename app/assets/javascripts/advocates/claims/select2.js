"use strict";

var adp = adp || {};

adp.select2 = {
  init : function() {
    $('.select2').select2({
      matcher: adp.select2.startOfMatcher
    });
  },
  startOfMatcher : function(term, text) {
    return text.toUpperCase().indexOf(term.toUpperCase()) == 0;
  }
};
