describe('Helpers.API.Core.js', function() {
  var controller = moj.Modules.ManagementInformation;

  var dateView = function(config) {
    var html = [
      '<div class="fx-dates-chooser">',
      '  <div class="form-group fx-start-date">',
      '  <fieldset>',
      '    <div class="form-date">',
      '      <div class="form-group form-group-day">',
      '        <label class="form-label" for="dob-day">Day</label>',
      '        <input class="form-control" id="dob-day" name="dob-day" pattern="[0-9]*" type="number">',
      '      </div>',
      '      <div class="form-group form-group-month">',
      '        <label class="form-label" for="dob-month">Month</label>',
      '        <input class="form-control" id="dob-month" name="dob-month" pattern="[0-9]*" type="number">',
      '      </div>',
      '      <div class="form-group form-group-year">',
      '        <label class="form-label" for="dob-year">Year</label>',
      '        <input class="form-control" id="dob-year" name="dob-year" pattern="[0-9]*" type="number">',
      '      </div>',
      '    </div>',
      '  </fieldset>',
      '  </div>',
      '  <div class="form-group fx-end-date">',
      '  <fieldset>',
      '    <div class="form-date">',
      '      <div class="form-group form-group-day">',
      '        <label class="form-label" for="dob-day">Day</label>',
      '        <input class="form-control" id="dob-day" name="dob-day" pattern="[0-9]*" type="number">',
      '      </div>',
      '      <div class="form-group form-group-month">',
      '        <label class="form-label" for="dob-month">Month</label>',
      '        <input class="form-control" id="dob-month" name="dob-month" pattern="[0-9]*" type="number">',
      '      </div>',
      '      <div class="form-group form-group-year">',
      '        <label class="form-label" for="dob-year">Year</label>',
      '        <input class="form-control" id="dob-year" name="dob-year" pattern="[0-9]*" type="number">',
      '      </div>',
      '    </div>',
      '  </fieldset>',
      '  </div>',
      '</div>'
    ];
    return html.join('');
  };

  beforeEach(function() {
    $('body').append(dateView({subcontext:'fx-start-date'}));
  });
  afterEach(function() {
    $('.fx-dates-chooser').remove();
  });

  it('...should exist', function() {
    expect(controller).toBeDefined();
  });

  it('...should have an `el` definded', function() {
    expect(controller.el).toBeDefined();
    expect(controller.el).toEqual('.fx-dates-chooser');
  });

  it('should have a `init` method', function() {
    expect(controller.init).toBeDefined();
  });

  describe('Methods', function() {
    describe('...init', function() {
      it('...should call `this.bindEvent` when `this.el` is present', function() {
        spyOn(controller, 'bindEvents');
        controller.init();
        expect(controller.bindEvents).toHaveBeenCalled();

        //remove the dom el
        //reset the calls
        //init and try again
        controller.$el.remove();
        controller.bindEvents.calls.reset();
        controller.init();
        expect(controller.bindEvents).not.toHaveBeenCalled();
      });
    });
  });
});
