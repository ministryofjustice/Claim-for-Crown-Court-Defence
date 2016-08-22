moj.Modules.SchemeFilter = {
  init: function() {
    var self = this;

    $('.js-claim-scheme-filter')
      .on('change', ':radio', function() {
        window.location = self.pathWithFilter($(this).val());
      });
  },

  // pathname returns the current url location without any query params
  pathWithFilter: function(scheme) {
    var param  = scheme !== 'all' ? '?scheme='+scheme : '';
    var anchor = '#listanchor';
    return window.location.pathname + param + anchor;
  }
};
