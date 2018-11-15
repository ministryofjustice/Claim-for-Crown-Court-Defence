describe('Modules.ManagementInformation.js', function() {
  var controller = moj.Modules.ManagementInformation;

  var dateView = function(config) {
    config = $.extend({
      startDate: {
        day: '',
        month: '',
        year: ''
      },
      endDate: {
        day: '',
        month: '',
        year: ''
      }
    }, config);
    var html = [
      '<div class="fx-dates-chooser">',
      '<input type="hidden" id="user_api_key" value="abcABC" />',
      '  <div class="form-group fx-start-date">',
      '  <fieldset>',
      '    <div class="form-date">',
      '      <div class="form-group form-group-day">',
      '        <label class="form-label" for="dob-day">Day</label>',
      '        <input class="form-control" id="dob-day" name="dob-day" pattern="[0-9]*" type="number" value="' + config.startDate.day + '">',
      '      </div>',
      '      <div class="form-group form-group-month">',
      '        <label class="form-label" for="dob-month">Month</label>',
      '        <input class="form-control" id="dob-month" name="dob-month" pattern="[0-9]*" type="number" value="' + config.startDate.month + '">',
      '      </div>',
      '      <div class="form-group form-group-year">',
      '        <label class="form-label" for="dob-year">Year</label>',
      '        <input class="form-control" id="dob-year" name="dob-year" pattern="[0-9]*" type="number" value="' + config.startDate.year + '">',
      '      </div>',
      '    </div>',
      '  </fieldset>',
      '  </div>',
      '  <div class="form-group fx-end-date">',
      '  <fieldset>',
      '    <div class="form-date">',
      '      <div class="form-group form-group-day">',
      '        <label class="form-label" for="dob-day">Day</label>',
      '        <input class="form-control" id="dob-day" name="dob-day" pattern="[0-9]*" type="number" value="' + config.endDate.day + '">',
      '      </div>',
      '      <div class="form-group form-group-month">',
      '        <label class="form-label" for="dob-month">Month</label>',
      '        <input class="form-control" id="dob-month" name="dob-month" pattern="[0-9]*" type="number" value="' + config.endDate.month + '">',
      '      </div>',
      '      <div class="form-group form-group-year">',
      '        <label class="form-label" for="dob-year">Year</label>',
      '        <input class="form-control" id="dob-year" name="dob-year" pattern="[0-9]*" type="number" value="' + config.endDate.year + '">',
      '      </div>',
      '    </div>',
      '  </fieldset>',
      '  </div>',
      '<a id="provisional_assessments_date_download">link</a>',
      '</div>'
    ];
    return html.join('');
  };

  beforeEach(function() {
    $('body').append(dateView());
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

    describe('...extractDates', function() {
      it('...should exist', function() {
        expect(controller.extractDates).toBeDefined();
      });
      it('...should return a well formed data object', function() {
        $('.fx-dates-chooser').remove();
        $('body').append(dateView({
          startDate: {
            day: '1',
            month: '2',
            year: '2017',
          },
          endDate: {
            day: '3',
            month: '4',
            year: '2018',
          }
        }));

        controller.init();
        expect(controller.extractDates()).toEqual({
          startDate: '2017-2-1',
          endDate: '2018-4-3'
        });
      });
    });

    describe('...buildDataArray', function() {
      it('...should call `this.extractDates`', function() {
        spyOn(controller, 'extractDates').and.callThrough();

        controller.init();
        controller.buildDataArray();

        expect(controller.extractDates).toHaveBeenCalled();
      });
      it('...should return a well formed object', function() {
        spyOn(controller, 'extractDates').and.callThrough();

        controller.init();
        var arr = controller.buildDataArray();

        expect(controller.extractDates).toHaveBeenCalled();
        expect(arr).toEqual({
          api_key: 'abcABC',
          start_date: '--',
          end_date: '--',
          format: 'csv'
        });


        $('.fx-dates-chooser').remove();
        $('body').append(dateView({
          startDate: {
            day: '1',
            month: '2',
            year: '2017',
          },
          endDate: {
            day: '3',
            month: '4',
            year: '2018',
          }
        }));

        controller.init();

        arr = controller.buildDataArray();

        expect(controller.extractDates).toHaveBeenCalled();
        expect(arr).toEqual({
          api_key: 'abcABC',
          start_date: '2017-2-1',
          end_date: '2018-4-3',
          format: 'csv'
        });
      });
    });

    describe('...buildAttributes', function() {
      it('...should call `this.buildDataArray`', function() {
        spyOn(controller, 'buildDataArray').and.callThrough();

        $('.fx-dates-chooser').remove();
        $('body').append(dateView({
          startDate: {
            day: '1',
            month: '2',
            year: '2017',
          },
          endDate: {
            day: '3',
            month: '4',
            year: '2018',
          }
        }));

        controller.init();
        var url = controller.buildAttributes();

        expect(controller.buildDataArray).toHaveBeenCalled();
        expect(url).toEqual('api_key=abcABC&start_date=2017-2-1&end_date=2018-4-3&format=csv')
      });
    });

    xdescribe('...disableDownloadButton', function() {
      // TODO
    });

    describe('...enableDownloadButton', function() {
      it('...should call `this.buildAttributes`', function() {
        spyOn(controller, 'buildAttributes').and.callThrough();

        $('.fx-dates-chooser').remove();
        $('body').append(dateView({
          startDate: {
            day: '1',
            month: '2',
            year: '2017',
          },
          endDate: {
            day: '3',
            month: '4',
            year: '2018',
          }
        }));

        controller.init();
        controller.enableDownloadButton();

        expect(controller.buildAttributes).toHaveBeenCalled();
        expect(controller.$download.attr('href')).toEqual('/api/mi/provisional_assessments?api_key=abcABC&start_date=2017-2-1&end_date=2018-4-3&format=csv');
        expect(controller.$download.hasClass('disabled')).toEqual(false);
      });
    });

    xdescribe('...activateDownload', function() {
      // TODO
    });

    xdescribe('...dateInputEvent', function() {
      // TODO
    });

    xdescribe('...blockDisabledLinkClick', function() {
      // TODO
    });
  });
});
