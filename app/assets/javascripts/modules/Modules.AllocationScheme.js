/**
 * Allocation Scheme controller
 */
moj.Modules.AllocationScheme = {
  // wrapper for the form controls
  el: '#allocation-filters',

  // to cache the el
  $el: null,

  /**
   * Auto called by moj wrapper
   * cache the el
   * bindEvents
   */
  init: function() {
    this.$el = $(this.el);
    this.bindEvents();
  },

  bindEvents: function() {

    /**
     * Publish the sheme change event
     * passng the value
     * Publish data: {object} {scheme: <input value>}
     */
    this.$el.on('change', 'input', function(e) {
      $.publish('/scheme/change/', {
        scheme: $(e.target).val()
      });
    });
  }
}