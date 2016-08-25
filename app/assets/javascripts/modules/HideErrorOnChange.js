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
  }, {
    delegate: '.dropdown_field_with_errors.has-select',
    wrapperClassName: 'dropdown_field_with_errors',
    messageSelector: '.error',
    eventSelector: 'select'
  }],

  init: function() {
    this.bindListeners();
  },
  removeClassName: function($el, className) {
    var nestedWrappers = $el.find('.field_with_errors');
    if(nestedWrappers.length){
      nestedWrappers.removeClass('field_with_errors');
    }
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
        self.removeBySelector($el, opt.messageSelector);
      });

      // mainly for FF
      $(opt.delegate).one('focus', context, function(e) {
        $(e.target).trigger('click');
      });
    });
  }
};