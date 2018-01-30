describe('Modules.DuplicateExpenseCtrl', function() {
  var domFixture = $('<div class="main" />');
  var view = [
    '<div class="mod-expenses">HWLLOOOOO',
    '<div class="expense-group">',
    '<input name="this[name][0][modelname]" value="12" />',
    '</div>',
    '<a class="fx-duplicate-expense" href="">Duplicate this expense</a>',
    '</div>'
  ].join('');

  beforeEach(function() {
    domFixture.empty();
    domFixture.append($(view));
    // $('body').append(domFixture);
    // reset to default state
    moj.Modules.DuplicateExpenseCtrl.init();
  });

  afterAll(function() {
    domFixture.empty();
  });

  it('should have a default `el` defined', function() {
    expect(moj.Modules.DuplicateExpenseCtrl.el).toEqual('.mod-expenses')
  });

  describe('Methods', function() {
    describe('...init', function() {
      beforeEach(function() {
        spyOn(moj.Modules.DuplicateExpenseCtrl, 'bindEvents');
      });
      it('...should call `bindEvents` if the DOM el exists', function() {
        $('body').append(domFixture);

        expect(moj.Modules.DuplicateExpenseCtrl.bindEvents).not.toHaveBeenCalled();
        moj.Modules.DuplicateExpenseCtrl.init()
        expect(moj.Modules.DuplicateExpenseCtrl.bindEvents).toHaveBeenCalled();
        domFixture.empty();
      });
    });

    describe('...step1', function() {
      it('...should be defined', function() {
        expect(moj.Modules.DuplicateExpenseCtrl.step1).toBeDefined()
      });
      it('...should call `$.publish` and `this.mapFormData`', function() {

        // set up spy
        spyOn($, 'publish').and.callThrough();
        spyOn(moj.Modules.DuplicateExpenseCtrl, 'mapFormData').and.returnValue($.when({a:'e'}));

        // expect not to be called
        expect($.publish).not.toHaveBeenCalled();
        expect(moj.Modules.DuplicateExpenseCtrl.mapFormData).not.toHaveBeenCalled();

        // // fire step 1
        moj.Modules.DuplicateExpenseCtrl.step1();

        // // expect to have been called
        expect($.publish).toHaveBeenCalledWith('/step1/complete/', { a: 'e' });
        expect(moj.Modules.DuplicateExpenseCtrl.mapFormData).toHaveBeenCalled();
      });
    });

    describe('...step2', function() {
      it('...should be defined', function() {
        expect(moj.Modules.DuplicateExpenseCtrl.step2).toBeDefined()
      });
    });

    describe('...getDataInput', function() {
      it('...should be defined', function() {
        expect(moj.Modules.DuplicateExpenseCtrl.getDataInput).toBeDefined()
      });
      it('...return the correct data in the correct format', function() {
        $('body').append(domFixture);

        expect(moj.Modules.DuplicateExpenseCtrl.getDataInput()).toEqual([{
          name: 'this[name][0][modelname]',
          value: '12'
        }]);

        domFixture.empty();
      })
    });

    describe('...getKeyName', function() {
      it('...should be defined', function() {
        expect(moj.Modules.DuplicateExpenseCtrl.getKeyName).toBeDefined()
      });
      it('...should return the correct output given the correct input', function() {
        var fixture = {
          name: 'this[is-the][0][modelname1]',
          value: 'false'
        }
        expect(moj.Modules.DuplicateExpenseCtrl.getKeyName(fixture)).toEqual('modelname1');
      });
    });

    describe('...mapFormData', function() {
      it('...should be defined', function() {
        expect(moj.Modules.DuplicateExpenseCtrl.mapFormData).toBeDefined()
      });

      it('...should return an `Object`', function() {
        $('body').append(domFixture);
        var def = moj.Modules.DuplicateExpenseCtrl.mapFormData()
        def.then(function(data) {
          expect(data).toEqual({
            modelname: "12"
          });
        })

        domFixture.empty();
      });
    });

    describe('...bindEvents', function() {
      it('should have `bindEvents` defined', function() {
        expect(moj.Modules.DuplicateExpenseCtrl.bindEvents).toBeDefined();
      });
      it('...should bind the `.fx-duplicate-expense` event', function() {
        var mod = moj.Modules.DuplicateExpenseCtrl;
        spyOn(mod, 'step1');
        expect(mod.step1).not.toHaveBeenCalled();
        $('.fx-duplicate-expense').click();
        expect(mod.step1).toHaveBeenCalled();
      });
      it('...should subscribe to `/step1/complete/` event', function() {
        var mod = moj.Modules.DuplicateExpenseCtrl;

        spyOn(mod, 'step2');

        expect(mod.step2).not.toHaveBeenCalled();

        $.publish('/step1/complete/', {
          data: 'object'
        });

        expect(mod.step2).toHaveBeenCalled();

      });
    });

  });
});