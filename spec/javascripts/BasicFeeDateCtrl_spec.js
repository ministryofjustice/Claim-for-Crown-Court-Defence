describe('Modules.BasicFeeDateCtrl', function() {
  var controller = moj.Modules.BasicFeeDateCtrl;

  it('should exist', function() {
    expect(moj.Modules.BasicFeeDateCtrl).toBeDefined();
  });

  it('should have `this.el` defined', function() {
    expect(moj.Modules.BasicFeeDateCtrl.el).toEqual('.fx-date-controller');
  });

  describe('...methods', function() {
    beforeEach(function() {
      var fixtureDom = [
        '<div class="dates-wrapper form-group fx-date-controller">',
        '<p>hallo</p>',
        '<div class="fee-dates">Fee dates</div>',
        '<button class="add_fields">Add button</button>',
        '</div>'
      ].join('');
      $('body').append(fixtureDom);
    });

    afterEach(function() {
      $('body').find('.fx-date-controller').remove();
    });

    describe('...init', function() {
      it('should set `this.$el`', function() {
        controller.$el = undefined;
        controller.init();
        expect(controller.$el.length).toEqual(1);
      });
      it('should call `this.loadState`', function() {
        spyOn(controller, 'loadState');
        controller.init();
        expect(controller.loadState).toHaveBeenCalled();
      });

      it('should call `this.bindEvents`', function() {
        spyOn(controller, 'bindEvents');
        controller.init();
        expect(controller.bindEvents).toHaveBeenCalled();
      });
    });
    describe('...loadState', function() {
      it('should call `this.setAddLinkState`', function() {
        spyOn(controller, 'setAddLinkState');
        controller.loadState();
        expect(controller.setAddLinkState).toHaveBeenCalled();
      });
    });
    describe('...bindEvents', function() {
      it('...call `this.setAddLinkState` after `cocoon:after-insert` event', function () {
        spyOn(controller,'setAddLinkState');
        controller.init();
        controller.$el.trigger('cocoon:after-insert');
        expect(controller.setAddLinkState).toHaveBeenCalled();
      });
      it('...call `this.setAddLinkState` after `cocoon:after-remove` event', function () {
        spyOn(controller,'setAddLinkState');
        controller.init();
        controller.$el.trigger('cocoon:after-remove');
        expect(controller.setAddLinkState).toHaveBeenCalled();
      });
    });
    describe('...setAddLinkState', function() {
      it('...should hide the `.add_fields` element', function() {
        controller.init();
        expect(controller.$el.find('.fee-dates:visible').length).toEqual(1);
        controller.$el.find('.add_fields').show();

        controller.setAddLinkState();
        expect(controller.$el.find('.add_fields').is(':visible')).toEqual(false);

      });
      it('...should show the `.add_fields` element', function() {
        controller.init();
        controller.$el.find('.fee-dates').hide();
        controller.setAddLinkState();
        expect(controller.$el.find('.add_fields').is(':visible')).toEqual(true);
      });
    });
  });
});
