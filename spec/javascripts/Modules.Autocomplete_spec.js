describe("Modules.Autocomplete", function() {

  var module = moj.Modules.Autocomplete;
  beforeEach(function() {});

  afterEach(function() {});

  describe('Methods', function() {
    describe('...init', function() {
      it('should call `this.doKickoff`', function() {
        spyOn(module, 'doKickoff');
        module.init();
        expect(module.doKickoff).toHaveBeenCalled();
      });

      it('should not call `this.typeaheadKickoff` if there are NO elements to bind', function() {
        spyOn(module, 'typeaheadKickoff');
        spyOn(module, 'doKickoff').and.returnValue(0);
        module.init();
        expect(module.typeaheadKickoff).not.toHaveBeenCalled();
      });

      it('should call `this.typeaheadKickoff` if there are elements to bind', function() {
        spyOn(module, 'typeaheadKickoff');
        spyOn(module, 'doKickoff').and.returnValue(1);
        module.init();
        expect(module.typeaheadKickoff).toHaveBeenCalled();
      });
    });

    describe('...bh', function() {
      it('should return a Bloodhound instance', function() {
        var bh;
        var data = {
          local: [{
            "id": "10",
            "displayName": "Up to and including PCMH transfer"
          }, {
            "id": "20",
            "displayName": "Before trial transfer"
          }]
        };
        bh = module.bh(data);
        expect(bh.all()).toEqual(data.local);
      });
    });

    describe('...sourceWithDefaults', function() {
      it('should return all results with no `q` specified', function() {
        var output;
        var sync = function(data) {
          output = data;
        };
        var result;
        var data = {
          local: [{
            "id": "10",
            "displayName": "Up to and including PCMH transfer"
          }, {
            "id": "20",
            "displayName": "Before trial transfer"
          }]
        };
        var bh = module.bh(data);

        module.sourceWithDefaults('', sync, bh);
        expect(output).toEqual(data.local);
        module.sourceWithDefaults('Be', sync, bh);
        expect(output).toEqual([data.local[1]]);
      });
    });


    describe('...typeaheadInit', function() {
      it('should throw and error if either param is undefined', function() {
        expect(function() {
          module.typeaheadInit();
        }).toThrowError('Missing params');
      });

      it('should call $.fn.typeahead', function(){
        spyOn($.fn, 'typeahead');
        module.typeaheadInit($('<input />'), []);
        expect($.fn.typeahead).toHaveBeenCalled();
      });
    });

    describe('...typeaheadInit', function() {
      it('should throw and error if either param is undefined', function() {
        expect(function() {
          module.typeaheadInit();
        }).toThrowError('Missing params');
      });

      it('should call $.fn.typeahead', function(){
        spyOn($.fn, 'typeahead');
        module.typeaheadInit($('<input />'), []);
        expect($.fn.typeahead).toHaveBeenCalled();
      });
    });
  });
});