describe("Modules.Accordisson", function() {
  var mojAccordion;
  var fixtureDom = ['<div id="claim-accordion">',
    '<div class="tab"></div><div class="tab"></div>',
    '<div class="panel" aria-hidden="true"><span></span><span></span><span></span></div>',
    '</div>'
  ].join('');

  beforeEach(function() {
    $('body').append(fixtureDom);
  });

  afterEach(function() {
    $('#claim-accordion').remove();
  });

  describe('...Methods', function() {
    describe('...init', function() {
      var attrName;
      var attrValue;
      var filterStr;
      beforeEach(function() {
        spyOn(moj.Modules.Accordion, 'cacheEl');
        spyOn(moj.Modules.Accordion, 'bindHandlers');
        moj.Modules.Accordion.$panels = {
          attr: function(a, b) {
            attrName = a;
            attrValue = b;
          }
        };

      });
      it('should call `this.cacheEl`', function() {
        moj.Modules.Accordion.init();
        expect(moj.Modules.Accordion.cacheEl).toHaveBeenCalled();
      });
      it('should call `this.bindHandlers`', function() {
        moj.Modules.Accordion.init();
        expect(moj.Modules.Accordion.bindHandlers).toHaveBeenCalled();
      });
      it('should set the `aria-hidden` attr on `this.$panels`', function() {
        moj.Modules.Accordion.init();
        expect(attrName).toBe('aria-hidden');
        expect(attrValue).toBe('true');
      });
    });

    describe('...handleTabKeyPress', function() {
      var e;
      var result;
      var stopPropagation;
      beforeEach(function() {
        stopPropagation = false;
        e = {
          altKey: undefined,
          keyCode: undefined,
          ctrlKey: undefined,
          stopPropagation: function() {
            stopPropagation = true;
            return;
          }
        };
      });
      it('should return `true` if `e.altKey` is defined', function() {
        e.altKey = true;
        result = moj.Modules.Accordion.handleTabKeyPress('', e);
        expect(result).toBe(true);
      });
      it('should return false and stop propagation for keyCodes: enter, space, left, up, right, down, home, end', function() {
        [13, 32, 37, 38, 39, 40, 36, 35].forEach(function(int) {
          e.keyCode = int;
          result = moj.Modules.Accordion.handleTabKeyPress('', e);
          expect(stopPropagation).toBe(true);
          expect(result).toBe(false);
        });
      });

      it('should handle `e.ctrlKey:undefined` for keyCodes: pageup, pagedown', function() {
        e.ctrlKey = undefined;
        [33, 34].forEach(function(int) {
          e.keyCode = int;
          result = moj.Modules.Accordion.handleTabKeyPress('', e);
          expect(stopPropagation).toBe(false);
          expect(result).toBe(true);
        });
      });

      it('should handle `e.ctrlKey:true` for keyCodes: pageup, pagedown', function() {
        e.ctrlKey = true;
        [33, 34].forEach(function(int) {
          e.keyCode = int;
          result = moj.Modules.Accordion.handleTabKeyPress('', e);
          expect(stopPropagation).toBe(true);
          expect(result).toBe(false);
        });
      });
      it('should return `true` for unmatched `e.keyCode`', function() {
        e.ctrlKey = true;
        [99, 98, 97].forEach(function(int) {
          e.keyCode = int;
          result = moj.Modules.Accordion.handleTabKeyPress('', e);
          expect(stopPropagation).toBe(false);
          expect(result).toBe(true);
        });
      });
    });

    describe('...handleTabFocus', function () {
      it('should call `$.addClass` with the correct params and return `true`', function () {
        var attrValue = '';
        var result;
        moj.Modules.Accordion.$tab = {
          addClass: function (a) {
            attrValue = a;
            return true;
          }
        };
        result = moj.Modules.Accordion.handleTabFocus();
        expect(result).toBe(true);
        expect(attrValue).toBe('focus');
      });
    });
    describe('...handleTabBlur', function () {
      it('should call `$.removeClass` with the correct params and return `true`', function () {
        var attrValue = '';
        var result;
        moj.Modules.Accordion.$tab = {
          removeClass: function (a) {
            attrValue = a;
            return true;
          }
        };
        result = moj.Modules.Accordion.handleTabBlur();
        expect(result).toBe(true);
        expect(attrValue).toBe('focus');
      });
    });
  });

  describe('...after init', function() {
    it('should have some default config', function() {
      expect(moj.Modules.Accordion.keyCodes.tab).toBe(9);
      expect(moj.Modules.Accordion.keyCodes.tab).toBe(9);
      expect(moj.Modules.Accordion.keyCodes.enter).toBe(13);
      expect(moj.Modules.Accordion.keyCodes.esc).toBe(27);
      expect(moj.Modules.Accordion.keyCodes.space).toBe(32);
      expect(moj.Modules.Accordion.keyCodes.pageup).toBe(33);
      expect(moj.Modules.Accordion.keyCodes.pagedown).toBe(34);
      expect(moj.Modules.Accordion.keyCodes.end).toBe(35);
      expect(moj.Modules.Accordion.keyCodes.home).toBe(36);
      expect(moj.Modules.Accordion.keyCodes.left).toBe(37);
      expect(moj.Modules.Accordion.keyCodes.up).toBe(38);
      expect(moj.Modules.Accordion.keyCodes.right).toBe(39);
      expect(moj.Modules.Accordion.keyCodes.down).toBe(40);
      expect(moj.Modules.Accordion.accordionId).toBe('claim-accordion');
    });


    it('should cache the `#claim-accordion` element', function() {
      moj.Modules.Accordion.init();

      expect(moj.Modules.Accordion.$panel[0].outerHTML).toBe(fixtureDom);
    });

    it('should cache the `.panel` element', function() {
      var fixtureHTML = $(fixtureDom).find('.panel')[0].outerHTML;

      moj.Modules.Accordion.init();
      expect(moj.Modules.Accordion.$panels[0].outerHTML).toBe(fixtureHTML);
    });

    it('should cache the `lastHeadingIndex`', function() {
      moj.Modules.Accordion.init();
      expect(moj.Modules.Accordion.lastHeadingIndex).toBe(1);
    });
  });
});