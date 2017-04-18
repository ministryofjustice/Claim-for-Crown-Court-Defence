var helpers = {
  view: function(options) {
    options = $.extend({
      blocktype: 'FeeBlock',
      sidebartype: 'fees',
      autovat: 'false',
      quantity: 0,
      rate: '0.00',
      total: '0.00'
    }, options);
    return this.viewCache(options);
  },
  viewCache: function(options) {
    var els = {
      rate: '<input value="' + options.rate + '" class="rate" min="0" max="99999" type="number" />',
      quantity: '<input value="' + options.quantity + '" class="quantity" min="0" max="99999" type="number" />',
      total: {
        input: '<input value="' + options.total + '" class="total" min="0" max="99999" type="number" />',
        span: '<span class="total" data-total="' + options.total + '">£' + options.total + '</span>'
      },
      wrapper: {
        open: '<div class="js-block" data-autovat="' + options.autovat + '" data-block-type="' + options.blocktype + '" data-type="' + options.sidebartype + '">',
        close: '</div>'
      }
    };

    var views = {
      FeeBlock: [
        els.wrapper.open,
        els.total.input,
        els.wrapper.close
      ],
      FeeBlockCalculator: [
        els.wrapper.open,
        els.rate,
        els.quantity,
        els.total.span,
        els.wrapper.close
      ]
    };
    return views[options.blocktype].join('');
  },
  insertView: function(blockView) {
    var wrapperBlockView = $([
      '<div id="claim-form"></div>'
    ].join(''));

    $('body').find('#claim-form').remove();
    wrapperBlockView.append(blockView);

    $('body').append(wrapperBlockView);
  },
  removeView: function() {
    // $('#claim-form').remove();
  }
};

describe('Basic Fees View', function() {
  var blockView, wrapperBlockView;

  afterEach(function() {
    helpers.removeView();
  });

  describe('...FeeBlock', function() {
    describe('...Apply Vat', function() {
      beforeEach(function() {
        blockView = function(options) {
          return $(helpers.view($.extend({}, {
            blocktype: 'FeeBlock',
            autovat: true
          }, options)));
        };
      });

      it('should default all totals to 0', function() {
        var block;
        helpers.insertView(blockView());
        moj.Modules.SideBar.init();

        block = moj.Modules.SideBar.blocks[0];

        expect(block.totals).toEqual({
          quantity: 0,
          rate: 0,
          amount: 0,
          total: 0,
          vat: 0,
          typeTotal: 0
        });
      });

      it('should scrape the DOM for values and add VAT', function() {
        var block;
        helpers.insertView(blockView({
          quantity: 0,
          rate: 0,
          total: 15
        }));
        moj.Modules.SideBar.init();

        block = moj.Modules.SideBar.blocks[0];

        expect(block.totals).toEqual({
          quantity: 0,
          rate: 0,
          amount: 0,
          total: 15,
          vat: 3,
          typeTotal: 15
        });
      });

      it('should update the totals correctly', function() {
        var block;
        helpers.insertView(blockView({
          total: 15
        }));
        moj.Modules.SideBar.init();

        block = moj.Modules.SideBar.blocks[0];

        block.$el.find('.total').val('22');
        block.reload();
        expect(block.totals).toEqual({
          quantity: 0,
          rate: 0,
          amount: 0,
          total: 22,
          vat: 4.4,
          typeTotal: 22
        });
      });

      it('should not update the totals if element is hidden', function() {
        var block;
        helpers.insertView(blockView({
          total: 15
        }));
        moj.Modules.SideBar.init();

        block = moj.Modules.SideBar.blocks[0];

        block.$el.find('.total').val('22');
        block.$el.hide();
        block.reload();

        expect(block.$el.find('.total').val()).toBe('22');
        expect(block.totals).toEqual({
          quantity: 0,
          rate: 0,
          amount: 0,
          total: 15,
          vat: 3,
          typeTotal: 15
        });
      });
    });
    describe('...NO Vat', function() {
      beforeEach(function() {
        blockView = function(options) {
          return $(helpers.view($.extend({}, {
            blocktype: 'FeeBlock',
            autovat: false
          }, options)));
        };

      });
      it('should scrape the DOM for values and NOT add VAT', function() {
        var block;
        helpers.insertView(blockView({
          total: 15
        }));
        moj.Modules.SideBar.init();

        block = moj.Modules.SideBar.blocks[0];

        expect(block.totals).toEqual({
          quantity: 0,
          rate: 0,
          amount: 0,
          total: 15,
          vat: 0,
          typeTotal: 15
        });
      });

      it('should update the totals correctly', function() {
        var block;
        helpers.insertView(blockView({
          total: 15
        }));
        moj.Modules.SideBar.init();

        block = moj.Modules.SideBar.blocks[0];

        block.$el.find('.total').val('22');
        block.reload();
        expect(block.totals).toEqual({
          quantity: 0,
          rate: 0,
          amount: 0,
          total: 22,
          vat: 0,
          typeTotal: 22
        });
      });
    });
  });

  describe('...FeeBlockCalculator', function() {
    describe('...Apply Vat', function() {
      beforeEach(function() {
        blockView = function(options) {
          return $(helpers.view($.extend({}, {
            blocktype: 'FeeBlockCalculator',
            autovat: true
          }, options)));
        };
      });

      it('should default all totals to 0', function() {
        var block;
        helpers.insertView(blockView());
        moj.Modules.SideBar.init();

        block = moj.Modules.SideBar.blocks[0];

        expect(block.totals).toEqual({
          quantity: 0,
          rate: 0,
          amount: 0,
          total: 0,
          vat: 0,
          typeTotal: 0
        });
      });

      it('should scrape the DOM for values and add VAT', function() {
        var block;
        helpers.insertView(blockView({
          quantity: 3,
          rate: 5,
          total: 15
        }));
        moj.Modules.SideBar.init();

        block = moj.Modules.SideBar.blocks[0];

        expect(block.totals).toEqual({
          quantity: 3,
          rate: 5,
          amount: 0,
          total: 15,
          vat: 3,
          typeTotal: 15
        });
      });

      it('should update the totals correctly', function() {
        var block;
        helpers.insertView(blockView({
          total: 15,
          quantity: 3,
          rate: 5
        }));
        moj.Modules.SideBar.init();

        block = moj.Modules.SideBar.blocks[0];

        block.$el.find('.quantity').val('4');
        block.$el.find('.rate').val('25');
        block.reload();
        expect(block.totals).toEqual({
          quantity: 4,
          rate: 25,
          amount: 0,
          total: 100,
          vat: 20,
          typeTotal: 100
        });
      });

      it('should not update the totals if element is hidden', function() {
        var block;
        helpers.insertView(blockView({
          rate: 25,
          quantity: 4,
          total: 100
        }));
        moj.Modules.SideBar.init();

        block = moj.Modules.SideBar.blocks[0];

        block.$el.find('.rate').val('11');
        block.$el.find('.quantity').val('2');
        block.$el.hide();
        block.reload();
        expect(block.$el.find('.total').data('total')).toBe(100);
        expect(block.totals).toEqual({
          quantity: 4,
          rate: 25,
          amount: 0,
          total: 100,
          vat: 20,
          typeTotal: 100
        });
      });
    });
    describe('...NO Vat', function() {
      beforeEach(function() {
        blockView = function(options) {
          return $(helpers.view($.extend({}, {
            blocktype: 'FeeBlockCalculator',
            autovat: false
          }, options)));
        };

      });
      it('should scrape the DOM for values and NOT add VAT', function() {
        var block;
        helpers.insertView(blockView({
          quantity: 11,
          rate: 13,
          total: 143
        }));
        moj.Modules.SideBar.init();

        block = moj.Modules.SideBar.blocks[0];

        expect(block.totals).toEqual({
          quantity: 11,
          rate: 13,
          amount: 0,
          total: 143,
          vat: 0,
          typeTotal: 143
        });
      });

      it('should update the totals correctly', function() {
        var block;
        helpers.insertView(blockView({
          rate: 27,
          quantity:3,
          total: 81
        }));
        moj.Modules.SideBar.init();

        block = moj.Modules.SideBar.blocks[0];

        block.$el.find('.rate').val('25');
        block.$el.find('.quantity').val('7');
        block.reload();
        expect(block.totals).toEqual({
          quantity: 7,
          rate: 25,
          amount: 0,
          total: 175,
          vat: 0,
          typeTotal: 175
        });
      });
    });
  });
});