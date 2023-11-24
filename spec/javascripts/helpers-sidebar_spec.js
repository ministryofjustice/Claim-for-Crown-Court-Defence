/* global spyOnEvent */

describe('Helpers.Blocks.js', function () {
  it('should exist with expected constructors', function () {
    expect(moj.Helpers.Blocks).toBeDefined()
    expect(moj.Helpers.Blocks.Base).toBeDefined()
    expect(moj.Helpers.Blocks.FeeBlock).toBeDefined()
    expect(moj.Helpers.Blocks.FeeBlockCalculator).toBeDefined()
  })

  describe('Methods', function () {
    describe('...formatNumber', function () {
      it('should format the numbers correctly', function () {
        const expected = {
          0: '£0.01',
          1: '£0.11',
          2: '£1.11',
          3: '£11.11',
          4: '£111.11',
          5: '£1,111.11',
          6: '£11,111.11',
          7: '£111,111,111.11'
        };

        ['0.01', '0.11', '1.11', '11.11', '111.11', '1111.11', '11111.11', '111111111.11'].forEach(function (val, idx) {
          expect(expected[idx]).toBe(moj.Helpers.Blocks.formatNumber(val))
        })
      })
    })
  })

  describe('Instances', function () {
    let instance

    describe('Base', function () {
      it('should have defaults set', function () {
        instance = new moj.Helpers.Blocks.Base()
        expect(instance.config).toEqual({
          type: '_Base',
          vatfactor: 0.2,
          autoVAT: false,
          mileageFactor: 0.45,
          metersPerMile: 1609.34
        })
      })

      it('should take an `options` object and overide', function () {
        instance = new moj.Helpers.Blocks.Base({
          type: 'TYPE',
          vatfactor: 99,
          autoVAT: false
        })
        expect(instance.config).toEqual({
          type: 'TYPE',
          vatfactor: 99,
          autoVAT: false,
          mileageFactor: 0.45,
          metersPerMile: 1609.34
        })
      })

      it('should cache referances to the DOM element', function () {
        const fixtureDom = ['<div class="js-block fx-do-init">', '<span>hello</span>', '</div>'].join('')
        $('body').append(fixtureDom)
        instance = new moj.Helpers.Blocks.Base({
          $el: $('.js-block'),
          el: fixtureDom
        })
        expect(instance.$el).toEqual($('.js-block'))
        expect(instance.el).toEqual(fixtureDom)
        $('.js-block').remove()
      })

      describe('Methods', function () {
        describe('...getConfig', function () {
          it('should return the correct `this.config` prop', function () {
            instance = new moj.Helpers.Blocks.Base({
              some: 'thing'
            })
            expect(instance.getConfig('type')).toBe('_Base')
            expect(instance.getConfig('some')).toBe('thing')
          })
        })

        describe('...updateTotals', function () {
          it('should return a info message', function () {
            instance = new moj.Helpers.Blocks.Base()
            expect(instance.updateTotals()).toBe('This method needs an override')
          })
        })

        describe('...isVisible', function () {
          it('should correctly return the `isVisible` status', function () {
            const fixtureDom = [
              '<div class="js-block fx-do-init">',
              '<span class="rate">rate</span>',
              '<span class="amount">amount</span>',
              '<span class="total">total</span>',
              '</div>'
            ].join('')
            $('body').append(fixtureDom)
            instance = new moj.Helpers.Blocks.Base({
              $el: $('.js-block'),
              el: fixtureDom
            })
            expect(instance.isVisible()).toBe(true)
            instance.$el.hide()
            expect(instance.isVisible()).toBe(false)
            $('.js-block').remove()
          })
        })

        describe('...applyVat', function () {
          it('should not apply 20% VAT by default', function () {
            instance = new moj.Helpers.Blocks.Base()
            instance.totals = {
              vat: 0,
              total: 100
            }
            instance.applyVat()
            expect(instance.totals.vat).toBe(0)
          })

          it('should not apply VAT if `autoVAT` is false', function () {
            instance = new moj.Helpers.Blocks.Base({
              autoVAT: false
            })
            instance.totals = {
              vat: 0,
              total: 100
            }
            instance.applyVat()
            expect(instance.totals.vat).toBe(0)
          })

          it('should use a configurable `config.vatfactor`', function () {
            instance = new moj.Helpers.Blocks.Base({
              vatfactor: 0.5,
              autoVAT: true
            })
            instance.totals = {
              vat: 0,
              total: 100
            }
            instance.applyVat()
            expect(instance.totals.vat).toBe(50)
          })
        })

        describe('...getVal', function () {
          beforeEach(function () {
            const fixtureDom = [
              '<div class="js-block fx-do-init">',
              '<input class="rate" value="22.22"/>',
              '<input class="amount" value="33.33"/>',
              '</div>'
            ].join('')
            $('body').append(fixtureDom)
            instance = new moj.Helpers.Blocks.Base({
              $el: $('.js-block'),
              el: fixtureDom
            })
          })

          afterEach(function () {
            $('.js-block').remove()
          })

          it('should return the input value given a selector', function () {
            expect(instance.getVal('.rate')).toBe(22.22)
            expect(instance.getVal('.amount')).toBe(33.33)
          })

          it('should return 0 if no value is found', function () {
            $('.js-block').find('.amount').remove()
            expect(instance.getVal('.amount')).toBe(0)
          })
        })

        describe('...getDataVal', function () {
          beforeEach(function () {
            const fixtureDom = [
              '<div class="js-block fx-do-init">',
              '<input class="total" data-total="44.44" value="44.44"/>',
              '</div>'
            ].join('')
            $('body').append(fixtureDom)
            instance = new moj.Helpers.Blocks.Base({
              $el: $('.js-block'),
              el: fixtureDom
            })
          })

          afterEach(function () {
            $('.js-block').remove()
          })

          it('should return the input value given a selector', function () {
            expect(instance.getDataVal('.total', 'total')).toBe(44.44)
          })

          it('should return `false` if no value is found', function () {
            $('.js-block').find('.total').remove()
            expect(instance.getDataVal('.total', 'total')).toBe(false)
          })
        })

        // TO DO
        describe('...setState', function () {
          beforeEach(function () {
            const fixtureDom = [
              '<div class="js-block fx-do-init">',
              '<input class="total" data-total="44.44" value="44.44"/>',
              '</div>'
            ].join('')
            $('body').append(fixtureDom)
            instance = new moj.Helpers.Blocks.Base({
              $el: $('.js-block'),
              el: fixtureDom
            })
          })

          afterEach(function () {
            $('.js-block').remove()
          })

          it('should throw an error if no element is found', function () {
            expect(function () {
              instance.setState('.tal', true)
            }).toThrowError('Selector did not return an element: .tal')
          })

          it('should set the visibility of the selector', function () {
            instance.setState('.total', true)
            expect(instance.$el.find('.total:visible').length).toEqual(1)

            instance.setState('.total', false)
            expect(instance.$el.find('.total:visible').length).toEqual(0)
          })
        })

        describe('...setVal', function () {
          beforeEach(function () {
            const fixtureDom = [
              '<div class="js-block fx-do-init">',
              '<input class="total" data-total="44.44" value="44.44"/>',
              '</div>'
            ].join('')
            $('body').append(fixtureDom)
            instance = new moj.Helpers.Blocks.Base({
              $el: $('.js-block'),
              el: fixtureDom
            })
          })

          afterEach(function () {
            $('.js-block').remove()
          })

          it('should throw an error if no element is found', function () {
            expect(function () {
              instance.setVal('.tal', 83.333339)
            }).toThrowError('Selector did not return an element: .tal')
          })

          it('should set the value of the selector', function () {
            instance.setVal('.total', 83.333339)
            expect(instance.$el.find('.total').val()).toEqual('83.333339')
          })
        })

        describe('...setNumber', function () {
          beforeEach(function () {
            const fixtureDom = [
              '<div class="js-block fx-do-init">',
              '<input class="total" data-total="44.44" value="44.44"/>',
              '</div>'
            ].join('')
            $('body').append(fixtureDom)
            instance = new moj.Helpers.Blocks.Base({
              $el: $('.js-block'),
              el: fixtureDom
            })
          })

          afterEach(function () {
            $('.js-block').remove()
          })

          it('should set the value of the selector', function () {
            instance.setNumber('.total', 83.333339)
            expect(instance.$el.find('.total').val()).toEqual('83.33')
          })
        })
      })
    })

    describe('FeeBlock', function () {
      it('should apply Base Methods and set config props on the instance', function () {
        const fixtureDom = [
          '<div class="js-block fx-do-init">',
          '</div>'
        ].join('')
        $('body').append(fixtureDom)
        instance = new moj.Helpers.Blocks.FeeBlock({
          type: 'FeeBlock',
          $el: $('.js-block'),
          el: fixtureDom
        })
        expect(instance.getConfig).toBeDefined()
        expect(instance.getConfig('type')).toEqual('FeeBlock')
        $('.js-block').remove()
      })

      describe('Methods', function () {
        let fixtureDom
        beforeEach(function () {
          fixtureDom = [
            '<div class="js-block fx-do-init">',
            '<input class="quantity" value="11.11"/>',
            '<input class="rate" value="22.22"/>',
            '<input class="amount" value="33.33"/>',
            '<span class="total" data-total="44.44" />',
            '<input class="vat" value=""/>',
            '</div>'
          ].join('')
          $('body').append(fixtureDom)
          instance = new moj.Helpers.Blocks.FeeBlock({
            $el: $('.js-block'),
            el: fixtureDom
          })
        })

        afterEach(function () {
          $('.js-block').remove()
        })

        describe('...init', function () {
          it('should call `this.bindEvents`', function () {
            spyOn(instance, 'bindEvents')
            instance.init()
            expect(instance.bindEvents).toHaveBeenCalled()
          })

          it('should call `this.bindRecalculate`', function () {
            spyOn(instance, 'bindRecalculate')
            instance.init()
            expect(instance.bindRecalculate).toHaveBeenCalled()
          })
        })

        describe('...bindEvents', function () {
          it('should call `this.bindRecalculate`', function () {
            spyOn(instance, 'bindRecalculate')
            instance.init()
            expect(instance.bindRecalculate).toHaveBeenCalled()
          })
        })

        describe('...bindRecalculate', function () {
          it('should bind a change event on specific elements', function () {
            spyOn(instance.$el, 'on')
            instance.bindRecalculate()
            expect(instance.$el.on).toHaveBeenCalledWith('change keyup', '.quantity, .rate, .amount, .vat, .total', jasmine.any(Function))
          })

          it('should trigger the `recalculate` event when `change` is fired', function () {
            spyOn(instance.$el, 'trigger')
            instance.bindRecalculate()
            instance.$el.find('.rate').trigger('change')
            expect(instance.$el.trigger).toHaveBeenCalledWith('recalculate')
          })
        })

        describe('...reload', function () {
          it('should call `updateTotals`', function () {
            spyOn(instance, 'updateTotals')
            instance.reload()

            expect(instance.updateTotals).toHaveBeenCalled()
          })

          it('should call `applyVat`', function () {
            spyOn(instance, 'applyVat')
            instance.reload()

            expect(instance.applyVat).toHaveBeenCalled()
          })
        })

        describe('...setTotals', function () {
          it('should return an updated `this.totals` object', function () {
            instance.$el.find('.rate').val('222.22')
            instance.$el.find('.amount').val('333.33')
            instance.$el.find('.total').data('total', '444.44')

            instance.setTotals()
            expect(instance.totals).toEqual({
              quantity: 11.11,
              rate: 222.22,
              amount: 333.33,
              total: 444.44,
              vat: 0,
              typeTotal: 444.44
            })
          })

          it('should handle missing `data-total` on the element', function () {
            instance.$el.find('.rate').val('222.22')
            instance.$el.find('.amount').val('333.33')
            instance.$el.find('.total').remove()
            instance.$el.append('<input class="total" />')
            instance.$el.find('.total').val('555.55')

            instance.setTotals()
            expect(instance.totals).toEqual({
              quantity: 11.11,
              rate: 222.22,
              amount: 333.33,
              total: 555.55,
              vat: 0,
              typeTotal: 555.55
            })
          })
        })

        describe('...updateTotals', function () {
          let called = false

          it('should call `this.isVisible`', function () {
            instance.isVisible = function () {
              called = true
            }
            instance.updateTotals()
            expect(called).toBe(true)
          })

          it('should return the current `this.totals` when element is hidden', function () {
            instance.totals = {
              current: 'total'
            }
            spyOn(instance, 'isVisible').and.returnValue(false)
            expect(instance.updateTotals()).toEqual({
              current: 'total'
            })
          })

          it('should call `this.setTotals` when `this.isVisible` returns true', function () {
            instance.totals = {
              current: 'total'
            }
            spyOn(instance, 'isVisible').and.returnValue(true)
            spyOn(instance, 'setTotals').and.returnValue('david')

            instance.updateTotals()

            expect(instance.isVisible).toHaveBeenCalled()
            expect(instance.setTotals).toHaveBeenCalled()
          })
        })
      })
    })

    describe('FeeBlockCalculator', function () {
      it('should apply Base Methods and set config props on the instance', function () {
        const fixtureDom = [
          '<div class="js-block fx-do-init">',
          '</div>'
        ].join('')
        $('body').append(fixtureDom)
        instance = new moj.Helpers.Blocks.FeeBlockCalculator({
          type: 'FeeBlockCalculator',
          $el: $('.js-block'),
          el: fixtureDom
        })
        expect(instance.setTotals).toBeDefined()
        expect(instance.bindRender).toBeDefined()
        expect(instance.init).toBeDefined()
        expect(instance.render).toBeDefined()
        $('.js-block').remove()
      })

      describe('Methods', function () {
        let fixtureDom
        beforeEach(function () {
          fixtureDom = [
            '<div class="js-block fx-do-init">',
            '<input class="quantity" value="11.11"/>',
            '<input class="rate" value="22.22"/>',
            '<input class="amount" value="33.33"/>',
            '<span class="total" data-total="44.44" />',
            '<input class="vat" value="88.88"/>',
            '</div>'
          ].join('')
          $('body').append(fixtureDom)
          instance = new moj.Helpers.Blocks.FeeBlockCalculator({
            $el: $('.js-block'),
            el: fixtureDom
          })
        })

        afterEach(function () {
          $('.js-block').remove()
        })

        describe('...init', function () {
          it('should call `this.bindRender`', function () {
            spyOn(instance, 'bindRender')
            instance.init()
            expect(instance.bindRender).toHaveBeenCalled()
          })
        })

        describe('...render', function () {
          it('should update the view correctly', function () {
            instance.totals.total = 1234567.89
            instance.render()
            expect(instance.$el.find('.total').data('total')).toBe(1234567.89)
          })
        })

        describe('...setTotals', function () {
          it('should set `this.totals` correctly', function () {
            instance.totals = {
              quantity: 'changeme',
              rate: 'changeme',
              amount: 'changeme',
              total: 'changeme',
              vat: 'changeme'
            }
            instance.setTotals()
            expect(instance.totals).toEqual({
              quantity: 11.11,
              rate: 22.22,
              amount: 33.33,
              total: 246.86,
              vat: 88.88,
              typeTotal: 246.86
            })
          })
        })

        describe('...bindRender', function () {
          it('should bind a change event on specific elements', function () {
            spyOn(instance.$el, 'on')
            instance.bindRender()
            expect(instance.$el.on).toHaveBeenCalledWith('change keyup', '.quantity, .rate', jasmine.any(Function))
          })

          it('should call `this.updateTotals` when `change` is fired', function () {
            spyOn(instance, 'updateTotals')
            instance.bindRender()
            instance.$el.find('.rate').trigger('change')
            expect(instance.updateTotals).toHaveBeenCalled()
          })

          it('should call `this.updateTotals` when `keyup` is fired', function () {
            spyOn(instance, 'updateTotals')
            instance.bindRender()
            instance.$el.find('.rate').trigger('keyup')
            expect(instance.updateTotals).toHaveBeenCalled()
          })

          it('should call `this.render` when `change` is fired', function () {
            spyOn(instance, 'render')
            instance.bindRender()
            instance.$el.find('.rate').trigger('change')
            expect(instance.render).toHaveBeenCalled()
          })

          it('should call `this.render` when `keyup` is fired', function () {
            spyOn(instance, 'render')
            instance.bindRender()
            instance.$el.find('.rate').trigger('keyup')
            expect(instance.render).toHaveBeenCalled()
          })
        })
      })
    })

    describe('ExpenseBlock', function () {
      describe('Defaults', function () {
        let fixtureDom

        beforeEach(function () {
          fixtureDom = [
            '<div class="js-block fx-do-init">',
            '</div>'
          ].join('')
          $('body').append(fixtureDom)

          instance = new moj.Helpers.Blocks.ExpenseBlock({
            type: 'ExpenseBlock',
            $el: $('.js-block'),
            el: fixtureDom
          })
        })

        afterEach(function () {
          $('.js-block').remove()
        })

        it('should apply Base Methods and set config props on the instance', function () {
          expect(instance.getConfig).toBeDefined()
          expect(instance.getConfig('type')).toEqual('ExpenseBlock')
        })

        it('should have `this.stateLookup` defined', function () {
          expect(instance.stateLookup).toEqual({
            vatAmount: '.fx-travel-vat-amount',
            reason: '.fx-travel-reason',
            netAmount: '.fx-travel-net-amount',
            location: '.fx-travel-location',
            hours: '.fx-travel-hours',
            distance: '.fx-travel-distance',
            destination: '.fx-travel-destination',
            date: '.fx-travel-date',
            mileage: '.fx-travel-mileage',
            grossAmount: '.fx-travel-gross-amount'
          })
        })

        it('should have `this.defaultstate` defined', function () {
          expect(instance.defaultstate).toEqual({
            mileage: false,
            date: false,
            distance: false,
            grossAmount: false,
            hours: false,
            location: false,
            netAmount: false,
            reason: false,
            vatAmount: false
          })
        })

        it('should have `this.expenseReasons` defined', function () {
          expect(instance.expenseReasons).toEqual({
            A: [{
              id: 1,
              reason: 'Court hearing',
              reason_text: false
            }, {
              id: 2,
              reason: 'Pre-trial conference expert witnesses',
              reason_text: false
            }, {
              id: 3,
              reason: 'Pre-trial conference defendant',
              reason_text: false
            }, {
              id: 4,
              reason: 'View of crime scene',
              reason_text: false
            }, {
              id: 5,
              reason: 'Other',
              reason_text: true
            }],
            B: [{
              id: 2,
              reason: 'Pre-trial conference expert witnesses',
              reason_text: false
            }, {
              id: 3,
              reason: 'Pre-trial conference defendant',
              reason_text: false
            }, {
              id: 4,
              reason: 'View of crime scene',
              reason_text: false
            }],
            C: [{
              id: 1,
              reason: 'Court hearing (Crown court)',
              location_type: 'crown_court',
              reason_text: false
            }, {
              id: 1,
              reason: "Court hearing (Magistrates' court)",
              location_type: 'magistrates_court',
              reason_text: false
            }, {
              id: 2,
              reason: 'Pre-trial conference expert witnesses',
              reason_text: false
            }, {
              id: 3,
              reason: 'Pre-trial conference defendant (prison)',
              location_type: 'prison',
              reason_text: false
            }, {
              id: 3,
              reason: 'Pre-trial conference defendant (hospital)',
              location_type: 'hospital',
              reason_text: false
            }, {
              id: 3,
              reason: 'Pre-trial conference defendant (other)',
              reason_text: false
            }, {
              id: 4,
              reason: 'View of crime scene',
              reason_text: false
            }, {
              id: 5,
              reason: 'Other',
              reason_text: true
            }]
          })
        })
      })

      describe('Methods', function () {
        let fixtureDom
        beforeEach(function () {
          fixtureDom = [
            '<div class="js-block fx-do-init">',
            '<p class="fx-general-errors" style="display: none;"><span></span></p>',
            '<input class="fx-location-model" value ="sample"/>',
            '<input class="quantity" value="11.11"/>',
            '<input class="rate" value="22.22"/>',
            '<input class="amount" value="33.33"/>',
            '<span class="total" data-total="44.44" />',
            '<div class="fx-travel-expense-type"><select><option value="">please select</option><option value="1">option selected</option></select></div>',
            '<div class="fx-travel-reason"><select><option value="">please select</option><option data-reason-text="true" value="1">option 1</option><option data-reason-text="false" value="2" data-location-type="test-location">option 2</option></select></div>',
            '<div class="fx-travel-reason-other" style="display:none"><span>here</span></div>',
            '<div class="fx-travel-location">',
            '<div class="location_wrapper"><label>Destination</label><input type="text" value=""></div>',
            '<div class="fx-establishment-select has-select" style="display:none;"><label class="form-label-bold" for="location">Destination</label><select id="location"><option value="">please select</option><option value="1" data-postcode="POSTCODE" selected>establishment selected</option></select></div>',
            '</div>',
            '<div class="fx-travel-mileage">',
            ' <div class="fx-travel-mileage-bike">',
            '   <input type="hidden" name="mileage_rate_id" value="" />',
            '   <div class="multiple-choice">',
            '     <input type="radio" value="3" name="mileage_rate_id" id="mileage_rate_id_3" />',
            '     <label for="mileage_rate_id_3">20p per mile</label>',
            '   </div>',
            ' </div>',
            ' <div class="fx-travel-mileage-car">',
            '   <input type="hidden" name="mileage_rate_id" value="" disabled="" />',
            '   <div class="multiple-choice">',
            '     <input type="radio" value="1" name="mileage_rate_id" id="mileage_rate_id_1" />',
            '     <label for="mileage_rate_id_1">25p per mile</label>',
            '   </div>',
            '   <div class="multiple-choice">',
            '     <input type="radio" value="2" name="mileage_rate_id" id="mileage_rate_id_2"/>',
            '     <label for="mileage_rate_id_2">45p per mile</label>',
            '   </div>',
            ' </div>',
            '</div>',
            '<div class="fx-travel-net-amount"><input value=""/></div>',
            '<div class="fx-travel-vat-amount"><input value=""/></div>',
            '<div class="fx-travel-distance"><input value=""/></div>',
            '<input class="vat" value=""/>',
            '</div>'
          ].join('')

          const el = $('<div id="claim-form" data-claim-id="99"><form><div id="expenses" data-feature-distance="true"></div></form></div>').append(fixtureDom)

          $('body').append(el)

          instance = new moj.Helpers.Blocks.ExpenseBlock({
            $el: $('.js-block'),
            el: fixtureDom
          })
        })

        afterEach(function () {
          $('#claim-form').remove()
          $('.js-block').remove()
        })

        describe('...init', function () {
          it('should call `this.bindEvents`', function () {
            spyOn(instance, 'bindEvents')
            instance.init()
            expect(instance.bindEvents).toHaveBeenCalled()
          })
          it('should call `this.loadCurrentState`', function () {
            spyOn(instance, 'loadCurrentState')
            instance.init()
            expect(instance.loadCurrentState).toHaveBeenCalled()
          })
          it('should update `this.config.fn`', function () {
            spyOn(instance, 'bindEvents')
            spyOn(instance, 'loadCurrentState')

            instance.init()
            expect(instance.config.fn).toEqual('ExpenseBlock')
            expect(instance.config.featureDistance).toEqual(true)
          })
        })

        describe('...bindEvents', function () {
          it('should call `this.bindRecalculate`', function () {
            spyOn(instance, 'bindRecalculate')
            instance.init()
            expect(instance.bindRecalculate).toHaveBeenCalled()
          })

          it('should call `this.bindListners`', function () {
            spyOn(instance, 'bindListners')
            instance.init()
            expect(instance.bindListners).toHaveBeenCalled()
          })
        })

        describe('...bindListners', function () {
          it('expense type: should bind change listner', function () {
            const selector = '.fx-travel-expense-type select'
            const spyEvent = spyOnEvent(selector, 'change')

            $(selector).trigger('change')

            expect('change').toHaveBeenTriggeredOn(selector)
            expect(spyEvent).toHaveBeenTriggered()
          })

          it('expense type: should handle change event', function () {
            const selector = '.fx-travel-expense-type select'
            instance.bindListners()
            spyOn(instance, 'statemanager')
            $(selector).trigger('change')

            expect(instance.statemanager).toHaveBeenCalledWith(selector)
          })

          it('travel reason: should bind change listner', function () {
            const selector = '.fx-travel-reason select:last'
            const spyEvent = spyOnEvent(selector, 'change')

            $(selector).trigger('change')

            expect('change').toHaveBeenTriggeredOn(selector)
            expect(spyEvent).toHaveBeenTriggered()
          })

          it('travel reason: should handle change event', function () {
            const selector = '.fx-travel-reason select:last'
            spyOn(instance, 'setVal')
            spyOn(instance, 'setLocationElement')

            instance.bindListners()
            $(selector).prop('selectedIndex', 1).trigger('change')

            expect(instance.$el.find('.fx-travel-reason-other').is(':visible')).toBe(true)

            $(selector).prop('selectedIndex', 2).trigger('change')
            expect(instance.$el.find('.fx-travel-reason-other').is(':visible')).toBe(false)
          })

          it('travel reason: should call `this.setVal` passing params', function () {
            const selector = '.fx-travel-reason select:last'
            spyOn(instance, 'setVal')
            spyOn(instance, 'setState')
            spyOn(instance, 'setLocationElement')

            instance.bindListners()
            $(selector).prop('selectedIndex', 1).trigger('change')

            expect(instance.setVal).toHaveBeenCalledWith('.fx-location-type', '')

            $(selector).prop('selectedIndex', 2).trigger('change')
            expect(instance.setVal).toHaveBeenCalledWith('.fx-location-type', 'test-location')
          })

          it('travel reason: should call `this.setState` passing params', function () {
            const selector = '.fx-travel-reason select:last'
            spyOn(instance, 'setVal')
            spyOn(instance, 'setState')
            spyOn(instance, 'setLocationElement')

            instance.bindListners()
            $(selector).prop('selectedIndex', 1).trigger('change')

            expect(instance.setState).toHaveBeenCalledWith('.fx-travel-reason-other', true)

            $(selector).prop('selectedIndex', 2).trigger('change')
            expect(instance.setState).toHaveBeenCalledWith('.fx-travel-reason-other', false)
          })

          it('travel reason: should call `this.setLocationElement` passing params', function () {
            const selector = '.fx-travel-reason select:last'
            spyOn(instance, 'setVal')
            spyOn(instance, 'setState')
            spyOn(instance, 'setLocationElement')

            instance.bindListners()
            $(selector).prop('selectedIndex', 1).trigger('change')

            expect(instance.setLocationElement).toHaveBeenCalledWith({
              reasonText: true
            })

            $(selector).prop('selectedIndex', 2).trigger('change')
            expect(instance.setLocationElement).toHaveBeenCalledWith({
              reasonText: false,
              locationType: 'test-location'
            })
          })

          it('establishment location: should bind change listner', function () {
            const selector = '.fx-establishment-select select:last'
            const spyEvent = spyOnEvent(selector, 'change')

            $(selector).trigger('change')

            expect('change').toHaveBeenTriggeredOn(selector)
            expect(spyEvent).toHaveBeenTriggered()
          })

          it('establishment location: should set the `.fx-location-model`', function () {
            const selector = '.fx-establishment-select select:last'

            instance.bindListners()
            $(selector).prop('selectedIndex', 1).trigger('change')

            expect($('.fx-location-model').val()).toEqual('establishment selected')
          })

          it('establishment location: should call `this.getDistance` if feature is enabled', function (done) {
            spyOn(instance, 'getDistance').and.returnValue(Promise.resolve())

            const selector = '.fx-establishment-select select:last'

            instance.bindListners()
            instance.distanceLookupEnabled = true
            $(selector).prop('selectedIndex', 1).trigger('change')

            expect(instance.getDistance).toHaveBeenCalledWith({
              claimid: 99,
              destination: 'POSTCODE'
            })
            done()
          })

          it('net amount: should bind keyup listner', function () {
            const selector = '.fx-travel-net-amount input'
            const spyEvent = spyOnEvent(selector, 'keyup')

            $(selector).keyup()

            expect('keyup').toHaveBeenTriggeredOn(selector)
            expect(spyEvent).toHaveBeenTriggered()
          })

          it('net amount: should update vat amount on key up', function () {
            const selector = '.fx-travel-net-amount input'
            spyOn(instance, 'setNumber')

            instance.bindListners()

            $(selector).val(11.35).keyup()
            expect(instance.setNumber).toHaveBeenCalledWith('.fx-travel-vat-amount input', 2.27)

            instance.config.vatfactor = 0.99

            $(selector).val(10.21).keyup()

            expect(instance.setNumber).toHaveBeenCalledWith('.fx-travel-vat-amount input', 10.1079)
          })
        })

        describe('...setLocationElement', function () {
          it('should exist as a function', function () {
            expect(instance.setLocationElement).toEqual(jasmine.any(Function))
          })

          it('should return an error if no params supplied', function () {
            expect(function () {
              instance.setLocationElement()
            }).toThrowError('Missing param: obj, cannot build element')
          })

          it('should call `this.attachSelectWithOptions` if param.locationType is supplied', function () {
            spyOn(instance, 'attachSelectWithOptions')
            instance.setLocationElement({
              locationType: 'not empty'
            })
            expect(instance.attachSelectWithOptions).toHaveBeenCalledWith('not empty', 'sample')
          })

          it('should call `this.attachSelectWithOptions` with param', function () {
            spyOn(instance, 'attachSelectWithOptions')
            instance.$el.find('.fx-location-model').val('')
            instance.setLocationElement({
              locationType: 'not empty'
            })
            expect(instance.attachSelectWithOptions).toHaveBeenCalledWith('not empty', '')
          })

          it('should call `this.displayLocationInput` ', function () {
            spyOn(instance, 'displayLocationInput')
            instance.$el.find('.fx-location-model').val('')
            instance.setLocationElement({
              locationType: undefined
            })
            expect(instance.displayLocationInput).toHaveBeenCalledWith()
          })
        })

        describe('...updateMileageElements', function () {
          it('...should calculate for 25p', function () {
            instance.init()

            // API success callback
            instance.updateMileageElements('1', false, {
              distance: 166956,
              miles: 104
            })
            expect(instance.$el.find('.fx-travel-distance input').val()).toEqual('104')
            expect(instance.$el.find('.fx-travel-net-amount input').val()).toEqual('')
            expect(instance.$el.find('.fx-travel-vat-amount input').val()).toEqual('')

            // Event binding callback
            instance.setNumber('.fx-travel-distance input', 583)
            instance.updateMileageElements('1')
            expect(instance.$el.find('.fx-travel-distance input').val()).toEqual('583')
            expect(instance.$el.find('.fx-travel-net-amount input').val()).toEqual('')
            expect(instance.$el.find('.fx-travel-vat-amount input').val()).toEqual('')
          })

          it('...should calculate for 45p', function () {
            instance.init()

            // API success callback
            instance.updateMileageElements('2', false, {
              distance: 166956,
              miles: 104
            })
            expect(instance.$el.find('.fx-travel-distance input').val()).toEqual('104')
            expect(instance.$el.find('.fx-travel-net-amount input').val()).toEqual('')
            expect(instance.$el.find('.fx-travel-vat-amount input').val()).toEqual('')

            // Event binding callback
            instance.setNumber('.fx-travel-distance input', 583)
            instance.updateMileageElements('2')
            expect(instance.$el.find('.fx-travel-distance input').val()).toEqual('583')
            expect(instance.$el.find('.fx-travel-net-amount input').val()).toEqual('')
            expect(instance.$el.find('.fx-travel-vat-amount input').val()).toEqual('')
          })

          it('...should calculate for 20p', function () {
            instance.init()

            // API success callback
            instance.updateMileageElements('3', false, {
              distance: 166956,
              miles: 104
            })
            expect(instance.$el.find('.fx-travel-distance input').val()).toEqual('104')
            expect(instance.$el.find('.fx-travel-net-amount input').val()).toEqual('')
            expect(instance.$el.find('.fx-travel-vat-amount input').val()).toEqual('')

            // Event binding callback
            instance.setNumber('.fx-travel-distance input', 583)
            instance.updateMileageElements('3')
            expect(instance.$el.find('.fx-travel-distance input').val()).toEqual('583')
            expect(instance.$el.find('.fx-travel-net-amount input').val()).toEqual('')
            expect(instance.$el.find('.fx-travel-vat-amount input').val()).toEqual('')
          })
        })

        describe('...getDistance', function () {
          it('should return the id and augmented distance object...', function (done) {
            const data = {
              distance: 204993
            }
            const resolvedData = Promise.resolve(data)
            spyOn(moj.Helpers.API.Distance, 'query').and.returnValue(resolvedData)
            instance.$el.find('#mileage_rate_id_1').prop('checked', true)
            instance.getDistance({
              claimid: 2,
              destination: 'POSTCODE'
            }).then(function (number, result) {
              expect(moj.Helpers.API.Distance.query).toHaveBeenCalledWith({
                claimid: 2,
                destination: 'POSTCODE'
              })

              expect(result).toEqual({
                distance: 204993,
                miles: 127
              })

              expect(number).toEqual('1')
              done()
            })
          })
          it('should populate and return an error ...', function (done) {
            const data = {
              error: 'error'
            }
            const resolvedData = Promise.reject(data)
            spyOn(moj.Helpers.API.Distance, 'query').and.returnValue(resolvedData)
            instance.$el.find('#mileage_rate_id_1').prop('checked', true)

            instance.getDistance({
              claimid: 2,
              destination: 'POSTCODE'
            }).then(undefined, function (result) {
              expect(moj.Helpers.API.Distance.query).toHaveBeenCalledWith({
                claimid: 2,
                destination: 'POSTCODE'
              })

              expect(result).toEqual('error')
              done()
            })
          })
        })

        describe('...displayLocationInput', function () {
          it('should update the view correctly', function () {
            instance.init()
            instance.displayLocationInput()
            expect(instance.$el.find('.fx-travel-location label:first').text()).toEqual('Destination')
            expect(instance.$el.find('.location_wrapper').css('display')).toEqual('block')
            expect(instance.$el.find('.fx-establishment-select').css('display')).toEqual('none')
          })
        })

        describe('...getRateId', function () {
          it('...should return the correct rateId', function () {
            instance.init()
            instance.$el.find('.fx-travel-mileage input[type=radio]:last').prop('checked', true)
            expect(instance.getRateId()).toEqual('2')
          })
        })

        describe('...viewErrorHandler', function () {
          it('...should set the correct view state', function () {
            instance.init()
            instance.viewErrorHandler('This is the message')
            expect(instance.$el.find('.fx-general-errors span').text()).toEqual('This is the message')
            expect(instance.$el.find('.fx-general-errors').is(':visible')).toEqual(true)
          })
        })

        describe('...attachSelectWithOptions', function () {
          const optionsFixture = ['<option value="">Please select</option>',
            '<option value="135" data-postcode="SY23 1AS">Aberystwyth Justice Centre</option>',
            '<option value="136" selected="" data-postcode="GU11 1NY">Aldershot Magistrates\' Court</option>',
            '<option value="137" data-postcode="HP6 5AJ">Amersham Law Courts</option>',
            '<option value="139" data-postcode="HP21 7QZ">Aylesbury Magistrates\' Court and Family Court</option>")'
          ]
          it('should return an error if no locationType', function () {
            instance.init()
            expect(function () {
              instance.attachSelectWithOptions()
            }).toThrowError('Missing param: locationType')
          })

          it('should call the Establishments API with the correct params ', function () {
            spyOn(moj.Helpers.API.Establishments, 'getAsSelectWithOptions').and.returnValue(Promise.resolve([]))
            instance.attachSelectWithOptions('crown_court', 'SomeThing')
            expect(moj.Helpers.API.Establishments.getAsSelectWithOptions).toHaveBeenCalledWith('crown_court', {
              prop: 'name',
              value: 'SomeThing'
            })
          })
          it('should update the view correctly', function (done) {
            const optionsFixtureData = Promise.resolve(optionsFixture)
            spyOn(moj.Helpers.API.Establishments, 'getAsSelectWithOptions').and.returnValue(optionsFixtureData)
            expect(instance.$el.find('.fx-establishment-select').is(':visible')).toEqual(false)
            expect(instance.$el.find('.fx-establishment-select option').length).toEqual(2)
            expect(instance.$el.find('.location_wrapper').is(':visible')).toEqual(true)
            expect(instance.$el.find('.fx-travel-location .has-select label').text()).toEqual('Destination')

            instance.attachSelectWithOptions('crown_court', 'SomeThing')
            optionsFixtureData.then(function () {
              expect(instance.$el.find('.fx-establishment-select').is(':visible')).toEqual(true)
              expect(instance.$el.find('.fx-establishment-select option').length).toEqual(5)
              expect(instance.$el.find('.location_wrapper').is(':visible')).toEqual(false)
              expect(instance.$el.find('.fx-travel-location .has-select label').text()).toEqual('Crown court')
              done()
            })
          })
        })
      })
    })
  })
})
