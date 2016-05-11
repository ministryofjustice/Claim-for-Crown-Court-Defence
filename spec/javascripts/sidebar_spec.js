describe("Side Bar", function() {
  var fixtureDom = $('<div class="grid-sidebar"/>');
  sideBarView = ['<div class="new-claim-hgroup js-stick-at-top-when-scrolling totals-summary">',
    '  <h2>Summary total</h2>',
    '  <h3>Fees total <span class="numeric total-fees" data-total-fees="£1.11">£1.11</span></h3>',
    '  <h3>Disbursements total <span class="numeric total-disbursements" data-total-disbursements="£1.22">£1.22</span></h3>',
    '  <h3>Expenses total <span class="numeric total-expenses" data-total-expenses="£1.33">£1.33</span></h3>',
    '  <h3>VAT total <span class="numeric total-vat" data-total-vat="£1.44">£1.44</span></h3>',
    '  <h3 class="total">Total<span class="numeric total-inc" data-total-inc="£1.55">£1.55</span></h3>',
    '</div>'
  ].join(' ');

  beforeEach(function() {
    fixtureDom.append(sideBarView);
    $('body').append(fixtureDom);

    // reset to default state 
    moj.Modules.SideBar.clearTotals();
  });

  afterEach(function() {
    fixtureDom.empty();
  });

  describe('Defaults', function() {
    it('should have an `el` defined', function() {
      expect(moj.Modules.SideBar.el).toEqual('.totals-summary');
    });
    it('should have an `claimForm` defined', function() {
      expect(moj.Modules.SideBar.claimForm).toEqual('#claim-form');
    });
    it('should have an `vatfactor` defined', function() {
      expect(moj.Modules.SideBar.vatfactor).toEqual(0.2);
    });
    it('should have an `totals` defined', function() {
      expect(moj.Modules.SideBar.totals).toEqual({
        fees: 0,
        disbursements: 0,
        expenses: 0,
        vat: 0,
        inc: 0
      });
    });
  });

  describe('Methods', function() {
    describe('...init', function() {

      beforeEach(function() {
        spyOn(moj.Modules.SideBar, 'bindListeners');
        spyOn(moj.Modules.SideBar, 'primeInternalCache');
      });
      it('should bind the listners', function() {
        moj.Modules.SideBar.init();
        expect(moj.Modules.SideBar.bindListeners).toHaveBeenCalled();
      });

      it('should prime the sidebar cache if the DOM element exists', function() {
        moj.Modules.SideBar.init();
        expect(moj.Modules.SideBar.primeInternalCache).toHaveBeenCalled();
      });

      it('should NOT prime the sidebar cache if the DOM element does not exists', function() {
        $('.grid-sidebar').remove();
        moj.Modules.SideBar.init();
        expect(moj.Modules.SideBar.primeInternalCache).not.toHaveBeenCalled();
      });
    });

    describe('...clearTotals', function() {
      it('should clear the totals cache obj', function() {
        var expected = {
          fees: 0,
          disbursements: 0,
          expenses: 0,
          vat: 0,
          inc: 0
        };
        moj.Modules.SideBar.totals = {
          fees: 1,
          disbursements: 2,
          expenses: 3,
          vat: 4,
          inc: 5
        };
        moj.Modules.SideBar.clearTotals();
        expect(moj.Modules.SideBar.totals).toEqual(expected);
      });
    });

    describe('...render', function() {
      it('should update the view correctly', function() {
        var $el;
        $el = $(moj.Modules.SideBar.el);

        moj.Modules.SideBar.totals = {
          fees: 11.34,
          disbursements: 4.34,
          expenses: 54.56,
          vat: 9.99,
          inc: 333
        };

        moj.Modules.SideBar.render();

        expect($el.find('.total-fees')[0].innerHTML).toBe('£11.34');
        expect($el.find('.total-disbursements')[0].innerHTML).toBe('£4.34');
        expect($el.find('.total-expenses')[0].innerHTML).toBe('£54.56');
        expect($el.find('.total-vat')[0].innerHTML).toBe('£9.99');
        expect($el.find('.total-inc')[0].innerHTML).toBe('£333.00');
      });

      it('should call `sanitzeFeeToFloat`', function() {
        spyOn(moj.Modules.SideBar, 'sanitzeFeeToFloat');
        moj.Modules.SideBar.render();
        expect(moj.Modules.SideBar.sanitzeFeeToFloat).toHaveBeenCalled();
      });
    });

    describe('...primeInternalCache', function() {
      it('should prime the cache correctly', function() {

        moj.Modules.SideBar.primeInternalCache();
        expect(moj.Modules.SideBar.totals).toEqual({
          fees: 1.11,
          disbursements: 1.22,
          expenses: 1.33,
          vat: 1.44,
          inc: 1.55
        });
      });

      it('should prime the cache correctly when data-attr is not set', function() {

        $('.total-disbursements').removeAttr('data-total-disbursements');

        moj.Modules.SideBar.primeInternalCache();
        expect(moj.Modules.SideBar.totals).toEqual({
          fees: 1.11,
          disbursements: 0,
          expenses: 1.33,
          vat: 1.44,
          inc: 1.55
        });
      });

      it('should call `this.render`', function() {
        spyOn(moj.Modules.SideBar, 'render');
        moj.Modules.SideBar.primeInternalCache();

        expect(moj.Modules.SideBar.render).toHaveBeenCalled();
      });
    });

    describe('...sanitzeFeeToFloat', function() {
      it('should sanitze the totals correctly', function() {
        var expected = {
          fees: 10.20,
          disbursements: 8.99,
          expenses: 4.90,
          vat: 0,
          inc: 0
        };
        moj.Modules.SideBar.totals = {
          fees: 10.20,
          disbursements: '£8.99',
          expenses: '£4.90',
          vat: 0,
          inc: 0
        };



        moj.Modules.SideBar.sanitzeFeeToFloat();
        expect(moj.Modules.SideBar.totals).toEqual(expected)
      });
    });

    

  });
});