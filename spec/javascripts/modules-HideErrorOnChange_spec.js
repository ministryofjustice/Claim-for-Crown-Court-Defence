describe("Modules.HideErrorOnChange.js", function() {

  var module = moj.Modules.HideErrorOnChange;
  var configFixture = [{
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
  }];

  describe('Config', function() {
    it('should have the correct config', function() {
      expect(module.config).toEqual(configFixture);
    });
  });

  describe('Methods', function() {
    describe('...init', function() {
      beforeEach(function() {
        spyOn(module, 'bindListeners');
      });
      it('should bind the listners', function() {
        module.init();
        expect(module.bindListeners).toHaveBeenCalled();
      });
    });

    describe('...removeClassName', function() {
      var $el;
      beforeEach(function() {
        $el = $('<div></div>');
        spyOn($el, 'removeClass');
      });
      it('should call $.fn.removeClass with params', function() {
        module.removeClassName($el, 'className');
        expect($el.removeClass).toHaveBeenCalledWith('className');
      });
    });

    describe('...removeBySelector', function() {
      var $el;
      beforeEach(function() {
        $el = $('<div><span class="error"></span></div>');
        spyOn($el, 'find').and.callThrough();
        spyOn($el, 'remove');
      });
      it('should call $.fn.removeClass with params', function() {
        module.removeBySelector($el, '.error');
        expect($el.find).toHaveBeenCalledWith('.error');
        expect($el.find('.error').length).toBe(0);
      });
    });
  });
});