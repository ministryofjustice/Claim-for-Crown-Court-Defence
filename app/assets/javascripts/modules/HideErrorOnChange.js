moj.Modules.HideErrorOnChange = {
  config: [{
    delegate: '.form-group.field_with_errors',
    wrapperClassName: 'field_with_errors',
    messageSelector: '.error'
  }, {
    delegate: '.dropdown_field_with_errors',
    wrapperClassName: 'dropdown_field_with_errors',
    messageSelector: '.error'
  }, {
    delegate: 'fieldset.gov_uk_date.error',
    wrapperClassName: 'error',
    messageSelector: 'ul'
  }],

  init: function() {
    this.bindListeners();
  },
  removeClassName: function($el, className) {
    return $el.removeClass(className);
  },
  removeBySelector: function($el, selector) {
    return $el.find(selector).remove();
  },
  bindListeners: function() {
    var self = this;
    this.config.forEach(function(opt) {
      $(opt.delegate).one('click', 'input', function(e) {
        var $el = $(e.delegateTarget);
        self.removeClassName($el, opt.wrapperClassName);
        self.removeBySelector($el, opt.messageSelector);
      });

      // mainly for FF
      $(opt.delegate).one('focus', 'input', function(e) {
        $(e.target).trigger('click');
      });
    });
  }
};