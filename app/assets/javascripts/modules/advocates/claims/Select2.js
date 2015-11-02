"use strict";

var moj = moj || {};

moj.Modules.Select2 = {
  init : function() {
    $('.select2').select2({
      matcher: this.startOfMatcher
    });
  },
  startOfMatcher : function(term, text) {
    return text.toUpperCase().indexOf(term.toUpperCase()) == 0;
  }
};
