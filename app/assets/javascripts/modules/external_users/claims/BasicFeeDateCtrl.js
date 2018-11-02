moj.Modules.BasicFeeDateCtrl = {
  el: '.fx-date-controller',
  init: function () {
    this.$el = $(this.el);
    this.bindEvents();
  },
  bindEvents: function () {
    var self = this;
    this.$el.on('cocoon:after-insert', function (e, el) {
      self.setAddLinkState();

    });

    this.$el.on('cocoon:after-remove', function (e, el) {
      self.setAddLinkState();
    });
  },
  setAddLinkState: function () {
    if(this.$el.find('.fee-dates').length){
      this.$el.find('.add_fields').hide();
      return;
    }
    this.$el.find('.add_fields').show();
  }
};
