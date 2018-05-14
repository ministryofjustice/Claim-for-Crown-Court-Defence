moj.Modules.HideErrorOnChange = {

  railsErrorClassName: 'field_with_errors',
  gdsErrorClassName: 'form-group-error',

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
  }, {
    delegate: '.gov_uk_date.form-group-error',
    wrapperClassName: 'error',
    messageSelector: 'ul'
  }, {
    delegate: '.dropdown_field_with_errors.has-select',
    wrapperClassName: 'dropdown_field_with_errors',
    messageSelector: '.error',
    eventSelector: 'select'
  }],

  init: function() {
    this.bindListeners();
  },

  removeNestedErrorWrappers: function($el) {
    var wrappers = $el.find('.' + this.railsErrorClassName);
    $el.find('.form-control-error').removeClass('form-control-error');
    wrappers.removeClass(this.railsErrorClassName);
  },

  removeClassName: function($el, className) {
    this.removeNestedErrorWrappers($el);
    return $el.removeClass(className);
  },

  removeBySelector: function($el, selector) {
    return $el.find(selector).remove();
  },

  bindListeners: function() {
    var self = this;
    var context;

    this.config.forEach(function(opt) {
      context = opt.eventSelector || 'input';
      $(opt.delegate).one('click', context, function(e) {
        var $el = $(e.delegateTarget);
        self.removeClassName($el, opt.wrapperClassName);
        self.removeClassName($el, 'form-group-error');
        self.removeBySelector($el, opt.messageSelector);

        return false;
      });

      // mainly for FF
      $(opt.delegate).one('focus', context, function(e) {
        $(e.target).trigger('click');
      });
    });
  }
};
