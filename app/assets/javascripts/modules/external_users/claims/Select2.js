moj.Modules.Select2 = {
  init : function() {
    $('.select2').select2({
      matcher: this.anyOfMatcher
    });
  },
  startOfMatcher : function(term, text) {
    return text.toUpperCase().indexOf(term.toUpperCase()) === 0;
  },
  anyOfMatcher : function(term, text) {
    return text.toUpperCase().indexOf(term.toUpperCase()) >= 0;
  }
};
