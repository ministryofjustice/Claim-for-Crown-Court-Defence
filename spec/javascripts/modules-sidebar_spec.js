describe("Modules.SideBar.js", function() {
  var sidebarFixtureDOM = $('<div class="grid-sidebar"/>');
  var jsBlocksFixtureDOM = $('<div class="block-hook"/>');
  var jsBlockFixtureDOM = $('<div id="claim-form"/>');

  var sideBarView = ['<div class="new-claim-hgroup js-stick-at-top-when-scrolling totals-summary">',
    '  <h2>Summary total</h2>',
    '  <h3>Fees total <span class="numeric total-fees" data-total-fees="£1.11">£1.11</span></h3>',
    '  <h3>Disbursements total <span class="numeric total-disbursements" data-total-disbursements="£1.22">£1.22</span></h3>',
    '  <h3>Expenses total <span class="numeric total-expenses" data-total-expenses="£1.33">£1.33</span></h3>',
    '  <h3>VAT total <span class="numeric total-vat" data-total-vat="£1.44">£1.44</span></h3>',
    '  <h3 class="total">Total<span class="numeric total-grandTotal" data-total-grandTotal="£1.55">£1.55</span></h3>',
    '</div>'
  ].join(' ');


  var jsBlockViewNonCalculated = $([
    '<div class="js-block nested-fields" ',
    '  data-autovat="true" ',
    '  data-calculated="false" ',
    '  data-type="fees">',
    '   <h1>JS BLOCK</h1>',
    '  <input value="" class="form-control quantity" min="0" max="99999" maxlength="5" size="5" type="number" name="claim[basic_fees_attributes][0][quantity]" id="claim_basic_fees_attributes_0_quantity">',
    '  <input value="0.00" class="form-control rate" size="10" maxlength="8" type="text">',
    '  <span class="total" data-total="0.0">£0.00</span>',
    '</div>'
  ].join(' '));

  var jsBlockViewCalculated = $([
    '<div class="js-block nested-fields" ',
    '  data-autovat="true" ',
    '  data-calculated="true" ',
    '  data-type="fees">',
    '   <h1>JS BLOCK</h1>',
    '  <input value="5" class="form-control quantity" min="0" max="99999" maxlength="5" size="5" type="number" name="claim[basic_fees_attributes][0][quantity]" id="claim_basic_fees_attributes_0_quantity">',
    '  <input value="5.20" class="form-control rate" size="10" maxlength="8" type="text">',
    '  <span class="total" data-total="31.20">£31.20</span>',
    '</div>'
  ].join(' '));

  beforeEach(function() {
    sidebarFixtureDOM.append(sideBarView);
    $('body').append(sidebarFixtureDOM);

    // reset to default state
    moj.Modules.SideBar.init();
  });

  afterEach(function() {
    sidebarFixtureDOM.empty();
  });

  describe('Defaults', function() {
    it('should have an `el` property defined', function() {
      expect(moj.Modules.SideBar.el).toEqual('.totals-summary');
    });
    it('should have a `claimForm` property defined', function() {
      expect(moj.Modules.SideBar.claimForm).toEqual('#claim-form');
    });
    it('should have a `vatfactor` property defined', function() {
      expect(moj.Modules.SideBar.vatfactor).toEqual(0.2);
    });
    it('should have a `totals` property defined', function() {
      expect(moj.Modules.SideBar.totals).toEqual({
        fees: 0,
        disbursements: 0,
        expenses: 0,
        vat: 0,
        grandTotal: 0
      });
    });
    it('should have a `blocks` property defined', function() {
      expect(moj.Modules.SideBar.blocks).toEqual([]);
    });
  });

  describe('Methods', function() {
    describe('...init', function() {

      beforeEach(function() {
        spyOn(moj.Modules.SideBar, 'bindListeners');
        spyOn(moj.Modules.SideBar, 'loadBlocks');
      });
      it('should bind the listners', function() {
        moj.Modules.SideBar.init();
        expect(moj.Modules.SideBar.bindListeners).toHaveBeenCalled();
      });

      it('should prime the sidebar cache if the DOM element exists', function() {
        moj.Modules.SideBar.init();
        expect(moj.Modules.SideBar.loadBlocks).toHaveBeenCalled();
      });
    });

    describe('...loadBlocks', function() {
      it('should clear the existing cache', function() {
        moj.Modules.SideBar.blocks = [{}, {}];

        jsBlockFixtureDOM.append([jsBlockViewNonCalculated.clone(), jsBlockViewNonCalculated.clone(), jsBlockViewNonCalculated.clone()]);
        $('body').append(jsBlockFixtureDOM);

        moj.Modules.SideBar.loadBlocks();

        expect(moj.Modules.SideBar.blocks.length).toBe(3);

        jsBlockFixtureDOM.empty();
      });
      it('should cache an instance of `FeeBlock` for every `.js-block` el', function() {
        var fixture = [
          jsBlockViewNonCalculated.clone(),
          jsBlockViewNonCalculated.clone(),
          jsBlockViewNonCalculated.clone()
        ];

        jsBlockFixtureDOM.append(fixture);
        $('body').append(jsBlockFixtureDOM);

        spyOn(moj.Helpers.SideBar, 'FeeBlock');
        moj.Modules.SideBar.loadBlocks();

        expect(moj.Helpers.SideBar.FeeBlock).toHaveBeenCalled();

        jsBlockFixtureDOM.empty();
      });
    });

    describe('...render', function() {
      it('should update the view correctly', function() {
        var $el;
        $el = $(moj.Modules.SideBar.el);

        moj.Modules.SideBar.totals = {
          fees: 54321.34,
          disbursements: 654321.34,
          expenses: 7654321.56,
          vat: 123456.99,
          grandTotal: 333
        };

        moj.Modules.SideBar.render();

        expect($el.find('.total-fees')[0].innerHTML).toBe('£54,321.34');
        expect($el.find('.total-disbursements')[0].innerHTML).toBe('£654,321.34');
        expect($el.find('.total-expenses')[0].innerHTML).toBe('£7,654,321.56');
        expect($el.find('.total-vat')[0].innerHTML).toBe('£123,456.99');
        expect($el.find('.total-grandTotal')[0].innerHTML).toBe('£333.00');
      });

      it('should call `sanitzeFeeToFloat`', function() {
        spyOn(moj.Modules.SideBar, 'sanitzeFeeToFloat');
        moj.Modules.SideBar.render();
        expect(moj.Modules.SideBar.sanitzeFeeToFloat).toHaveBeenCalled();
      });
    });

    describe('...recalculate', function() {
      describe('...internal calls', function() {
        var called;
        beforeEach(function() {
          spyOn(moj.Modules.SideBar, 'clearTotals');
          spyOn(moj.Modules.SideBar, 'render');
          called = {};
          moj.Modules.SideBar.blocks = [{
            type: 'fees',
            totals: {
              total: 10,
              vat: 2
            },
            isVisible: function() {
              called.isVisible = true;
              return 'called';
            },
            reload: function() {
              called.reload = true;
              return 'reloaded';
            },
            getConfig: function() {
              called.getConfig = true;
              return 'config';
            }
          }];
        });

        it('should call `this.clearTotals`', function() {
          moj.Modules.SideBar.recalculate();
          expect(moj.Modules.SideBar.clearTotals).toHaveBeenCalled();
        });

        it('should call `this.render`', function() {
          moj.Modules.SideBar.recalculate();
          expect(moj.Modules.SideBar.render).toHaveBeenCalled();
        });

        it('should call `isVisible` on the block instance', function() {
          moj.Modules.SideBar.recalculate();
          expect(called.isVisible).toBe(true);
        });

        it('should call `reload` on the block instance', function() {
          moj.Modules.SideBar.recalculate();
          expect(called.reload).toBe(true);
        });

        it('should call `getConfig` on the block instance', function() {
          moj.Modules.SideBar.recalculate();
          expect(called.getConfig).toBe(true);
        });

        describe('...calculations', function() {
          it('should add to the correct `this.type` property', function() {
            $('body').append(jsBlockViewCalculated);
            moj.Modules.SideBar.init();
            moj.Modules.SideBar.recalculate();

            expect(moj.Modules.SideBar.totals).toEqual({
              fees: 26,
              disbursements: 0,
              expenses: 0,
              vat: 5.2,
              grandTotal: 31.2
            });

            moj.Modules.SideBar.blocks[0].config.type = 'expenses';

            moj.Modules.SideBar.recalculate();

            expect(moj.Modules.SideBar.totals).toEqual({
              fees: 26,
              disbursements: 0,
              expenses: 26,
              vat: 10.4,
              grandTotal: 62.4
            });
          });
        });
      });
    });

    describe('...bindListeners', function() {
      it('should bind the listeners to the dom elements', function() {
        spyOn(jQuery.fn, 'on');
        moj.Modules.SideBar.bindListeners();
        expect(jQuery.fn.on).toHaveBeenCalled();
      });

      it('should call the correct callback for events', function() {
        spyOn(moj.Modules.SideBar, 'recalculate');
        spyOn(moj.Modules.SideBar, 'loadBlocks');

        moj.Modules.SideBar.bindListeners();

        $('#claim-form').trigger('recalculate');
        expect(moj.Modules.SideBar.recalculate).toHaveBeenCalled();
        expect(moj.Modules.SideBar.loadBlocks).not.toHaveBeenCalled();

        moj.Modules.SideBar.recalculate.calls.reset();
        moj.Modules.SideBar.loadBlocks.calls.reset();

        $('#claim-form').trigger('cocoon:after-insert');
        expect(moj.Modules.SideBar.recalculate).not.toHaveBeenCalled();
        expect(moj.Modules.SideBar.loadBlocks).toHaveBeenCalled();
      });
    });

    describe('...clearTotals', function() {
      it('should clear the totals cache obj', function() {
        var expected = {
          fees: 0,
          disbursements: 0,
          expenses: 0,
          vat: 0,
          grandTotal: 0
        };
        moj.Modules.SideBar.totals = {
          fees: 1,
          disbursements: 2,
          expenses: 3,
          vat: 4,
          grandTotal: 5
        };
        moj.Modules.SideBar.clearTotals();
        expect(moj.Modules.SideBar.totals).toEqual(expected);
      });
    });

    describe('...sanitzeFeeToFloat', function() {
      it('should sanitze the totals correctly', function() {
        var expected = {
          fees: 10.20,
          disbursements: 4558.99,
          expenses: 4.90,
          vat: 0,
          grandTotal: 0
        };
        moj.Modules.SideBar.totals = {
          fees: 10.20,
          disbursements: '£4,558.99',
          expenses: '£4.90',
          vat: 0,
          grandTotal: 0
        };

        moj.Modules.SideBar.sanitzeFeeToFloat();
        expect(moj.Modules.SideBar.totals).toEqual(expected);
      });
    });
  });
});