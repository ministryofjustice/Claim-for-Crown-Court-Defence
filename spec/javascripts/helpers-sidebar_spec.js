describe('Helpers.SideBar.js', function() {
  it('should exist with expected constructures', function() {
    expect(moj.Helpers.SideBar).toBeDefined();
    expect(moj.Helpers.SideBar.Base).toBeDefined();
    expect(moj.Helpers.SideBar.FeeBlock).toBeDefined();
  });

  describe('Methods', function() {
    describe('...addCommas', function() {
      it('should format the numbers correctly', function() {
        var expected = {
          0: '0.01',
          1: '0.11',
          2: '1.11',
          3: '11.11',
          4: '111.11',
          5: '1,111.11',
          6: '11,111.11',
          7: '111,111,111.11'
        };

        ['0.01', '0.11', '1.11', '11.11', '111.11', '1111.11', '11111.11', '111111111.11'].forEach(function(val, idx) {
          expect(expected[idx]).toBe(moj.Helpers.SideBar.addCommas(val));
        });
      });
    });
  });

  describe('Instances', function() {
    var instance;
    beforeEach(function() {});

    describe('Base', function() {
      it('should have defaults set', function() {
        instance = new moj.Helpers.SideBar.Base();
        expect(instance.config).toEqual({
          type: '_Base',
          vatfactor: 0.2,
          autoVAT: true
        });
      });

      it('should take an `options` object and overide', function() {
        instance = new moj.Helpers.SideBar.Base({
          type: 'TYPE',
          vatfactor: 99,
          autoVAT: false
        });
        expect(instance.config).toEqual({
          type: 'TYPE',
          vatfactor: 99,
          autoVAT: false
        });
      });

      it('should cache referances to the DOM element', function() {
        var fixtureDom = ['<div class="js-block">', '<span>hello</span>', '</div>'].join('');
        $('body').append(fixtureDom);
        instance = new moj.Helpers.SideBar.Base({
          $el: $('.js-block'),
          el: fixtureDom
        });
        expect(instance.$el).toEqual($('.js-block'));
        expect(instance.el).toEqual(fixtureDom);
        $('.js-block').remove();
      });

      describe('Methods', function() {
        describe('...getConfig', function() {
          it('should return the correct `this.config` prop', function() {
            instance = new moj.Helpers.SideBar.Base({
              some: 'thing'
            });
            expect(instance.getConfig('type')).toBe('_Base');
            expect(instance.getConfig('some')).toBe('thing');
          });
        });

        describe('...updateTotals', function() {
          it('should return a info message', function() {
            instance = new moj.Helpers.SideBar.Base();
            expect(instance.updateTotals()).toBe('This method needs an override');
          });
        });

        describe('...isVisible', function() {
          it('should correctly return the `isVisible` status', function() {
            var fixtureDom = [
              '<div class="js-block">',
              '<span class="rate">rate</span>',
              '<span class="amount">amount</span>',
              '<span class="total">total</span>',
              '</div>'
            ].join('');
            $('body').append(fixtureDom);
            instance = new moj.Helpers.SideBar.Base({
              $el: $('.js-block'),
              el: fixtureDom
            });
            expect(instance.isVisible()).toBe(true);
            instance.$el.find('.rate').hide();
            expect(instance.isVisible()).toBe(true);
            instance.$el.find('.amount').hide();
            expect(instance.isVisible()).toBe(true);
            instance.$el.find('.total').hide();
            expect(instance.isVisible()).toBe(false);
            $('.js-block').remove();
          });
        });

        describe('...applyVat', function() {
          it('should apply 20% VAT by default', function() {
            instance = new moj.Helpers.SideBar.Base();
            instance.totals = {
              vat: 0,
              total: 100
            };
            instance.applyVat();
            expect(instance.totals.vat).toBe(20);
          });

          it('should not apply VAT if `autoVAT` is false', function() {
            instance = new moj.Helpers.SideBar.Base({
              autoVAT: false
            });
            instance.totals = {
              vat: 0,
              total: 100
            };
            instance.applyVat();
            expect(instance.totals.vat).toBe(0);
          });

          it('should use a configurable `config.vatfactor`', function() {
            instance = new moj.Helpers.SideBar.Base({
              vatfactor: 0.5
            });
            instance.totals = {
              vat: 0,
              total: 100
            };
            instance.applyVat();
            expect(instance.totals.vat).toBe(50);
          });
        });

        describe('...getVal', function() {
          beforeEach(function() {
            var fixtureDom = [
              '<div class="js-block">',
              '<input class="rate" value="22.22"/>',
              '<input class="amount" value="33.33"/>',
              '</div>'
            ].join('');
            $('body').append(fixtureDom);
            instance = new moj.Helpers.SideBar.Base({
              $el: $('.js-block'),
              el: fixtureDom
            });
          });

          afterEach(function() {
            $('.js-block').remove();
          });

          it('should return the input value given a selector', function() {
            expect(instance.getVal('.rate')).toBe(22.22);
            expect(instance.getVal('.amount')).toBe(33.33);
          });

          it('should return 0 if no value is found', function() {
            $('.js-block').find('.amount').remove();
            expect(instance.getVal('.amount')).toBe(0);
          });
        });

        describe('...getDataVal', function() {
          beforeEach(function() {
            var fixtureDom = [
              '<div class="js-block">',
              '<input class="total" data-total="44.44" value="44.44"/>',
              '</div>'
            ].join('');
            $('body').append(fixtureDom);
            instance = new moj.Helpers.SideBar.Base({
              $el: $('.js-block'),
              el: fixtureDom
            });
          });

          afterEach(function() {
            $('.js-block').remove();
          });

          it('should return the input value given a selector', function() {
            expect(instance.getDataVal('total')).toBe(44.44);
          });

          it('should return `false` if no value is found', function() {
            $('.js-block').find('.total').remove();
            expect(instance.getDataVal('total')).toBe(false);
          });
        });
      });
    });

    describe('FeeBlock', function() {
      it('should apply Base Methods and set config props on the instance', function() {
        var fixtureDom = [
          '<div class="js-block">',
          '</div>'
        ].join('');
        $('body').append(fixtureDom);
        instance = new moj.Helpers.SideBar.FeeBlock({
          type: 'sample',
          $el: $('.js-block'),
          el: fixtureDom
        });
        expect(instance.getConfig).toBeDefined();
        expect(instance.getConfig('type')).toEqual('sample');
      });

      describe('Methods', function() {
        var fixtureDom;
        beforeEach(function() {
          fixtureDom = [
            '<div class="js-block">',
            '<input class="quantity" value="11.11"/>',
            '<input class="rate" value="22.22"/>',
            '<input class="amount" value="33.33"/>',
            '<span class="total" data-total="44.44" />',
            '<input class="vat" value=""/>',
            '</div>'
          ].join('');
          $('body').append(fixtureDom);
          instance = new moj.Helpers.SideBar.FeeBlock({
            $el: $('.js-block'),
            el: fixtureDom
          });
        });

        afterEach(function() {
          $('.js-block').remove();
        });

        describe('...reload', function() {
          it('should call `updateTotals` & `applyVat`', function() {
            var called1 = false;
            var called2 = false;

            instance.updateTotals = function() {
              called1 = true;
            };
            instance.applyVat = function() {
              called2 = true;
            };

            instance.reload();

            expect(called1).toBe(true);
            expect(called2).toBe(true);
          });

          it('should call reload when instantiated', function() {
            expect(instance.totals).toEqual({
              quantity: 11.11,
              rate: 22.22,
              amount: 33.33,
              total: 44.44,
              vat: 8.888
            });
          });
        });

        describe('...updateTotals', function() {
          var called = false;
          it('should call `this.isVisible`', function() {
            instance.isVisible = function() {
              called = true;
            };
            instance.updateTotals();
            expect(called).toBe(true);
          });

          it('should return the current `this.totals` when element is hidden', function() {
            $('.js-block').find('.rate').val(99.99);
            instance.updateTotals();
            expect(instance.totals.rate).toBe(99.99);
            $('.js-block').find('.rate').val(55.55);
            $('.js-block').hide();
            instance.updateTotals();
            expect(instance.totals.rate).toBe(99.99);
          });
          it('should return an updated `this.totals` object', function() {
            instance.$el.find('.rate').val('222.22');
            instance.$el.find('.amount').val('333.33');
            instance.$el.find('.total').data('total', '444.44');

            instance.updateTotals();
            expect(instance.totals).toEqual({
              quantity: 11.11,
              rate: 222.22,
              amount: 333.33,
              total: 444.44,
              vat: 0
            });
          });
        });
      });
    });
  });
});