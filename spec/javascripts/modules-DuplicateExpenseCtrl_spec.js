describe('Modules.DuplicateExpenseCtrl', function () {
  const domFixture = $('<div class="main" />')
  const view = [
    '<div class="mod-expenses">HWLLOOOOO',
    '<div class="expense-group">',
    '<input name="this[name][0][modelname]" value="12" />',
    '</div>',
    '<a class="fx-duplicate-expense" href="">Duplicate this expense</a>',
    '<a class="add_fields" href="">Add another expense</a>',
    '</div>'
  ].join('')

  beforeEach(function () {
    domFixture.append($(view))
    $('body').append(domFixture);

    // reset to default state
    moj.Modules.DuplicateExpenseCtrl.init()
  })

  afterEach(function () {
    domFixture.empty()
  })

  it('should have a default `el` defined', function () {
    expect(moj.Modules.DuplicateExpenseCtrl.el).toEqual('.mod-expenses')
  })

  describe('Methods', function () {
    describe('...init', function () {
      beforeEach(function () {
        spyOn(moj.Modules.DuplicateExpenseCtrl, 'bindEvents')
      })
      it('...should call `bindEvents` if the DOM el exists', function () {
        $('body').append(domFixture)

        expect(moj.Modules.DuplicateExpenseCtrl.bindEvents).not.toHaveBeenCalled()
        moj.Modules.DuplicateExpenseCtrl.init()
        expect(moj.Modules.DuplicateExpenseCtrl.bindEvents).toHaveBeenCalled()
        domFixture.empty()
      })
    })

    describe('...bindEvents', function () {
      it('should have `bindEvents` defined', function () {
        expect(moj.Modules.DuplicateExpenseCtrl.bindEvents).toBeDefined()
      })
      it('...should bind the `.fx-duplicate-expense` event', function () {
        const mod = moj.Modules.DuplicateExpenseCtrl
        spyOn(mod, 'step1')
        expect(mod.step1).not.toHaveBeenCalled()
        $('.fx-duplicate-expense').trigger('click')
        expect(mod.step1).toHaveBeenCalled()
      })
      it('...should subscribe to `/step1/complete/` event', function () {
        const mod = moj.Modules.DuplicateExpenseCtrl

        spyOn(mod, 'step2')

        expect(mod.step2).not.toHaveBeenCalled()

        $.publish('/step1/complete/', {
          data: 'object'
        })

        expect(mod.step2).toHaveBeenCalled()
      })
    })

    describe('...step1', function () {
      it('...should be defined', function () {
        expect(moj.Modules.DuplicateExpenseCtrl.step1).toBeDefined()
      })
      it('...should call `$.publish` and `this.mapFormData`', function (done) {
        const data = { a: 'e' }
        const resolvedData = Promise.resolve(data)
        // set up spy
        spyOn($, 'publish')
        spyOn(moj.Modules.DuplicateExpenseCtrl, 'mapFormData').and.returnValue(resolvedData)

        // expect not to be called
        expect($.publish).not.toHaveBeenCalled()
        expect(moj.Modules.DuplicateExpenseCtrl.mapFormData).not.toHaveBeenCalled()

        // // fire step 1
        moj.Modules.DuplicateExpenseCtrl.step1()
        expect(moj.Modules.DuplicateExpenseCtrl.mapFormData).toHaveBeenCalled()
        resolvedData.then(function () {
        // expect to have been called
          expect($.publish).toHaveBeenCalledWith('/step1/complete/', {
            a: 'e'
          })
          done()
        })
      })
    })

    describe('...step2', function () {
      it('...should be defined', function () {
        expect(moj.Modules.DuplicateExpenseCtrl.step2).toBeDefined()
      })
    })

    describe('...getFormData', function () {
      it('...should be defined', function () {
        expect(moj.Modules.DuplicateExpenseCtrl.getFormData).toBeDefined()
      })
      it('...return the correct data in the correct format', function () {
        $('body').append(domFixture)

        expect(moj.Modules.DuplicateExpenseCtrl.getFormData()).toEqual([{
          name: 'this[name][0][modelname]',
          value: '12'
        }])

        domFixture.empty()
      })
    })

    describe('...getKeyName', function () {
      it('...should be defined', function () {
        expect(moj.Modules.DuplicateExpenseCtrl.getKeyName).toBeDefined()
      })
      it('...should return the correct output given the correct input', function () {
        const fixture = {
          name: 'this[is-the][0][modelname1]',
          value: 'false'
        }
        expect(moj.Modules.DuplicateExpenseCtrl.getKeyName(fixture)).toEqual('modelname1')
      })
    })

    describe('...mapFormData', function () {
      it('...should be defined', function () {
        expect(moj.Modules.DuplicateExpenseCtrl.mapFormData).toBeDefined()
      })

      it('...should return an `Object`', function (done) {
        $('body').append(domFixture)
        const def = moj.Modules.DuplicateExpenseCtrl.mapFormData()
        def.then(function (data) {
          expect(data).toEqual({
            modelname: '12'
          })
          done()
        })
        domFixture.empty()
      })
    })
  })
})
