describe('Modules.ManagementInformation.js', function () {
  const controller = moj.Modules.ManagementInformation

  const dateView = function (config) {
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
    }, config)
    const html = [
      '<div class="fx-dates-chooser">',
      '  <input id="user_api_key" value="abcABC" type="hidden" name="user_api_key">',
      '  <div class="fx-start-date">',
      '    <div class="govuk-form-group">',
      '      <fieldset class="govuk-fieldset" aria-describedby="dob1-hint">',
      '        <legend class="govuk-fieldset__legend govuk-fieldset__legend--m">Start date</legend>',
      '        <div class="govuk-date-input">',
      '          <div class="govuk-date-input__item">',
      '            <div class="govuk-form-group">',
      '              <label class="govuk-label govuk-date-input__label" for="_dob1_3i">Day</label>',
      '              <input id="_dob1_3i" class="govuk-input govuk-date-input__input govuk-input--width-2" name="[dob1(3i)]" type="text" pattern="[0-9]*" inputmode="numeric" value="' + config.startDate.day + '">',
      '            </div>',
      '          </div>',
      '          <div class="govuk-date-input__item">',
      '            <div class="govuk-form-group">',
      '              <label class="govuk-label govuk-date-input__label" for="_dob1_2i">Month</label>',
      '              <input id="_dob1_2i" class="govuk-input govuk-date-input__input govuk-input--width-2" name="[dob1(2i)]" type="text" pattern="[0-9]*" inputmode="numeric"value="' + config.startDate.month + '">',
      '            </div>',
      '          </div>',
      '          <div class="govuk-date-input__item">',
      '            <div class="govuk-form-group">',
      '              <label class="govuk-label govuk-date-input__label" for="_dob1_1i">Year</label>',
      '              <input id="_dob1_1i" class="govuk-input govuk-date-input__input govuk-input--width-4" name="[dob1(1i)]" type="text" pattern="[0-9]*" inputmode="numeric" value="' + config.startDate.year + '">',
      '            </div>',
      '          </div>',
      '        </div>',
      '      </fieldset>',
      '    </div>',
      '  </div>',
      '  <div class="fx-end-date">',
      '    <div class="govuk-form-group">',
      '      <fieldset class="govuk-fieldset" aria-describedby="dob2-hint">',
      '        <legend class="govuk-fieldset__legend govuk-fieldset__legend--m">End date</legend>',
      '        <div class="govuk-date-input">',
      '          <div class="govuk-date-input__item">',
      '            <div class="govuk-form-group">',
      '              <label class="govuk-label govuk-date-input__label" for="_dob2_3i">Day</label>',
      '              <input id="_dob2_3i" class="govuk-input govuk-date-input__input govuk-input--width-2" name="[dob2(3i)]" type="text" pattern="[0-9]*" inputmode="numeric" value="' + config.endDate.day + '">',
      '            </div>',
      '          </div>',
      '          <div class="govuk-date-input__item">',
      '            <div class="govuk-form-group">',
      '              <label class="govuk-label govuk-date-input__label" for="_dob2_2i">Month</label>',
      '              <input id="_dob2_2i" class="govuk-input govuk-date-input__input govuk-input--width-2" name="[dob2(2i)]" type="text" pattern="[0-9]*" inputmode="numeric"value="' + config.endDate.month + '">',
      '            </div>',
      '          </div>',
      '          <div class="govuk-date-input__item">',
      '            <div class="govuk-form-group">',
      '              <label class="govuk-label govuk-date-input__label" for="_dob2_1i">Year</label>',
      '              <input id="_dob2_1i" class="govuk-input govuk-date-input__input govuk-input--width-4" name="[dob2(1i)]" type="text" pattern="[0-9]*" inputmode="numeric" value="' + config.endDate.year + '">',
      '            </div>',
      '          </div>',
      '        </div>',
      '      </fieldset>',
      '    </div>',
      '  </div>',
      '  <a id="provisional_assessments_date_download">link</a>',
      '</div>'
    ]
    return html.join('')
  }

  beforeEach(function () {
    $('body').append(dateView())
    controller.init()
  })

  afterEach(function () {
    $('.fx-dates-chooser').remove()
  })

  it('...should exist', function () {
    expect(controller).toBeDefined()
  })

  it('...should have an `el` definded', function () {
    expect(controller.el).toBeDefined()
    expect(controller.el).toEqual('.fx-dates-chooser')
  })

  it('should have a `init` method', function () {
    expect(controller.init).toBeDefined()
  })

  describe('Methods', function () {
    describe('...init', function () {
      it('...should call `this.bindEvent` when `this.el` is present', function () {
        spyOn(controller, 'bindEvents')
        controller.init()
        expect(controller.bindEvents).toHaveBeenCalled()
      })

      it('...should not call `this.bindEvent` when `this.el` is not present', function () {
        spyOn(controller, 'bindEvents')
        controller.$el.remove()
        controller.init()
        expect(controller.bindEvents).not.toHaveBeenCalled()
      })
    })

    describe('...extractDates', function () {
      it('...should exist', function () {
        expect(controller.extractDates).toBeDefined()
      })

      it('...should return a well formed data object', function () {
        $('.fx-dates-chooser').remove()
        $('body').append(dateView({
          startDate: {
            day: '1',
            month: '2',
            year: '2017'
          },
          endDate: {
            day: '3',
            month: '4',
            year: '2018'
          }
        }))

        controller.init()
        expect(controller.extractDates()).toEqual({
          startDate: '2017-2-1',
          endDate: '2018-4-3'
        })
      })
    })

    describe('...buildDataArray', function () {
      it('...should call `this.extractDates`', function () {
        spyOn(controller, 'extractDates').and.callThrough()

        controller.buildDataArray()

        expect(controller.extractDates).toHaveBeenCalled()
      })

      it('...should return a well formed object', function () {
        spyOn(controller, 'extractDates').and.callThrough()

        let arr = controller.buildDataArray()

        expect(controller.extractDates).toHaveBeenCalled()
        expect(arr).toEqual({
          api_key: 'abcABC',
          start_date: '--',
          end_date: '--',
          format: 'csv'
        })

        $('.fx-dates-chooser').remove()
        $('body').append(dateView({
          startDate: {
            day: '1',
            month: '2',
            year: '2017'
          },
          endDate: {
            day: '3',
            month: '4',
            year: '2018'
          }
        }))

        controller.init()

        arr = controller.buildDataArray()

        expect(controller.extractDates).toHaveBeenCalled()
        expect(arr).toEqual({
          api_key: 'abcABC',
          start_date: '2017-2-1',
          end_date: '2018-4-3',
          format: 'csv'
        })
      })
    })

    describe('...buildAttributes', function () {
      it('...should call `this.buildDataArray`', function () {
        spyOn(controller, 'buildDataArray').and.callThrough()

        $('.fx-dates-chooser').remove()
        $('body').append(dateView({
          startDate: {
            day: '1',
            month: '2',
            year: '2017'
          },
          endDate: {
            day: '3',
            month: '4',
            year: '2018'
          }
        }))

        controller.init()
        const url = controller.buildAttributes()

        expect(controller.buildDataArray).toHaveBeenCalled()
        expect(url).toEqual('api_key=abcABC&start_date=2017-2-1&end_date=2018-4-3&format=csv')
      })
    })

    describe('...disableDownloadButton', function () {
      it('should disable the download button', function () {
        controller.$download = {
          hasClass: jasmine.createSpy().and.returnValue(false),
          attr: jasmine.createSpy().and.returnValue(undefined),
          trigger: jasmine.createSpy()
        }

        $('body').append(dateView())
        controller.init()
        controller.disableDownloadButton()

        expect(controller.$download.hasClass('disabled')).toBeTrue()
        expect(controller.$download.attr('aria-disabled')).toBe('true')
        expect(controller.$download.attr('href')).toBeUndefined()
      })
    })

    describe('...enableDownloadButton', function () {
      it('...should call `this.buildAttributes`', function () {
        spyOn(controller, 'buildAttributes').and.callThrough()

        $('.fx-dates-chooser').remove()
        $('body').append(dateView({
          startDate: {
            day: '1',
            month: '2',
            year: '2017'
          },
          endDate: {
            day: '3',
            month: '4',
            year: '2018'
          }
        }))

        controller.init()
        controller.enableDownloadButton()

        expect(controller.buildAttributes).toHaveBeenCalled()
        expect(controller.$download.attr('href')).toEqual('/api/mi/provisional_assessments?api_key=abcABC&start_date=2017-2-1&end_date=2018-4-3&format=csv')
        expect(controller.$download.hasClass('disabled')).toBeFalse()
        expect(controller.$download.attr('aria-disabled')).toBe('false')
      })
    })

    describe('...activateDownload', function () {
      it('should enable the download button for valid dates', function () {
        spyOn(controller, 'enableDownloadButton')

        $('.fx-dates-chooser').remove()
        $('body').append(dateView({
          startDate: {
            day: '1',
            month: '01',
            year: '2025'
          },
          endDate: {
            day: '21',
            month: '1',
            year: '2025'
          }
        }))

        controller.init()

        expect(controller.activateDownload()).toBeTrue()
        expect(controller.enableDownloadButton).toHaveBeenCalled()
      })

      it('should disable the download button for invalid dates', function () {
        spyOn(controller, 'disableDownloadButton')

        $('.fx-dates-chooser').remove()
        $('body').append(dateView({
          startDate: {
            day: 'invalid',
            month: 'date',
            year: '2025'
          },
          endDate: {
            day: 'invalid',
            month: 'date',
            year: '2025'
          }
        }))

        controller.init()

        expect(controller.activateDownload()).toBeFalse()
        expect(controller.disableDownloadButton).toHaveBeenCalled()
      })
    })

    describe('...dateInputEvent', function () {
      it('should call activateDownload on keyup', function () {
        spyOn(controller, 'activateDownload')

        const input = $('.fx-start-date input').first()
        input.trigger('keyup')

        expect(controller.activateDownload).toHaveBeenCalled()
      })
    })

    describe('...blockDisabledLinkClick', function () {
      it('should prevent default click event if button is disabled', function () {
        controller.disableDownloadButton()

        const event = $.Event('click')
        spyOn(event, 'preventDefault')

        controller.$download.trigger(event)

        expect(event.preventDefault).toHaveBeenCalled()
      })

      it('should not prevent default click event if button is enabled', function () {
        controller.enableDownloadButton()

        const event = $.Event('click')
        spyOn(event, 'preventDefault')

        controller.$download.trigger(event)

        expect(event.preventDefault).not.toHaveBeenCalled()
      })
    })
  })
})
