moj.Modules.AllocationFilters = {
  el: '#allocation-filters',
  $el: null,
  init: function() {
    this.$el = $(this.el);
    this.bindEvents();
    console.log('init: Modules.AllocationFilters', this);
  },
  bindEvents: function() {
    this.$el.on('change', 'input', function(e) {
      $.publish('/scheme/change/', {
        scheme: $(e.target).val()
      });
    });
  }
}