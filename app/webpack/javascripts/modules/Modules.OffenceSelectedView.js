/**
 * OffenceSelectedView View controller
 * @type {Object}
 */
moj.Modules.OffenceSelectedView = {

  // view wrapper
  view: '.fx-view-selectedOffence',

  // hidden field that stores the rails model
  model: '.fx-model',

  /**
   * Util method to check view visibility
   * @return Boolean
   */
  isVisible: function(){
    return this.$view.is(':visible');
  },

  /**
   * init called my moj.init()
   */
  init: function() {
    // check if the view exists for binding events
    this.$view = $(this.view);

    if (this.$view.length) {
      this.bindEvents();

      // hide the main page buttons
      $.publish('/office/search/pageControls/', false)
    }
  },


  bindEvents: function() {
    var self = this;

    /**
     * Clear selection procedure
     * clear hidden rails model
     * hide the view
     * show page controls
     */
    this.$view.on('click', '.fx-clear-selection', function(e) {
      e.preventDefault();
      $(self.model).val('');
      self.$view.hide();
      $.publish('/office/search/pageControls/', true)
    });
  }
}
