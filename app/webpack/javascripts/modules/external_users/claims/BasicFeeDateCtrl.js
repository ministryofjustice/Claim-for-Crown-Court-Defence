moj.Modules.BasicFeeDateCtrl = {
  el: '.fx-date-controller',
  init: function() {
    this.$el = $(this.el);
    this.loadState();
    this.bindEvents();

  },
  loadState: function() {
    this.setAddLinkState();
  },
  bindEvents: function() {
    var self = this;
    this.$el.on('cocoon:after-insert', function() {
      self.setAddLinkState();
    });

    this.$el.on('cocoon:after-remove', function() {
      self.setAddLinkState();
    });
  },
  setAddLinkState: function() {
    if (this.$el.find('.fee-dates:visible').length) {
      this.$el.find('.add_fields').hide();
      return;
    }
    this.$el.find('.add_fields').show();
  }
};
