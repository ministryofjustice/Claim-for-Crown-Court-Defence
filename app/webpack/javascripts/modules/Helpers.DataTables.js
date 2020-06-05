/**
 * DataTables jQuery initializer
 * @type {Object}
 */
moj.Helpers.DataTables = {
  _defaultOptions: {
    /**
     * https://datatables.net/reference/option/deferRender
     * @type {Boolean}
     */
    deferRender: true
  },

  /**
   * API that will return a instance of jQuery DataTables
   * @param  {object} options https://datatables.net/reference/option/
   * @param  {string} el      DOM element
   * @return {object}         https://datatables.net/reference/api/
   */
  init: function(options, el) {
    var __options = $.extend({}, this._defaultOptions, options || {});
    return $(el || '#example').DataTable(__options);
  }
};
