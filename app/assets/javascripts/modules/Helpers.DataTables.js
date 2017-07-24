moj.Helpers.DataTables = {
  _defaultOptions: {
    deferRender: true
  },
  init: function(options, el) {
    var __options = $.extend({}, this._defaultOptions, options || {});
    return $(el || '#example').DataTable(__options);
  }
}