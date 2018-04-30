describe("Modules.OffenceSearchInput.js", function() {
  var module = moj.Modules.OffenceSearchInput;

  var view = function(data) {

    data = $.extend({}, data, {
      value: ''
    });
    return $([
      '<div class="form-group mod-search-input">',
      '  <label class="form-label" for="offence">',
      '    Search for the offence',
      '    <span class="form-hint">For example class, band, offence or act name</span>',
      '    <a class="fx-clear-search" href="#noop">Clear search</a>',
      '    <input autocomplete="off" class="fx-input" id="offence" name="offence-search-input" type="input" value="' + data.value + '">',
      '  </label>',
      '  <input value="' + data.value + '" class="fx-model" type="hidden" name="claim[offence_id]" id="claim_offence_id" />',
      '</div>'
    ].join(''));
  }


  beforeEach(function() {
    $('body .mod-search-input').remove();
    $('body').append(view());
  });

  afterEach(function() {

  });

  describe('...defaults', function() {
    it('`this.el`', function() {
      expect(module.el).toEqual('.mod-search-input')
    });
    it('`this.input`', function() {
      expect(module.input).toEqual('.fx-input')
    });
    it('`this.model`', function() {
      expect(module.model).toEqual('.fx-model')
    });
    it('`this.debouce`', function() {
      expect(module.debouce).toEqual(500)
    });
    it('`this.subscribers`', function() {
      expect(module.subscribers).toEqual({
        run: '/offence/search/run/',
        filter: '/offence/search/filter/'
      })
    });
    it('`this.publishers`', function() {
      expect(module.publishers).toEqual({
        results: '/offence/search/results/'
      })
    });
  });


  describe('...Methods', function() {
    describe('...init', function() {
      it('should check the dom and `init` if required, caching a `$el` referance ', function() {
        spyOn(module, 'bindEvents');

        module.init();
        expect(module.bindEvents).toHaveBeenCalled();
        expect(module.$el.length).toEqual(1)
        expect(module.$input.length).toEqual(1)
        expect(module.$model.length).toEqual(1)
      });
    });

    describe('...bindEvents', function() {
      it('should bind `clearSearch`', function() {
        spyOn(module, 'clearSearch')
        spyOn(module, 'trackUserInput');
        module.init();
        expect(module.clearSearch).toHaveBeenCalled();
        expect(module.trackUserInput).toHaveBeenCalled();
      });
    });

    describe('...bindSubscribers', function() {
      it('should subscribe to the `this.subscribers.run` event', function() {
        spyOn(module, 'runQuery');
        module.init();

        $.publish('/offence/search/run/')

        expect(module.runQuery).toHaveBeenCalled();
      });
    });

    describe('...runQuery', function() {
      it('should construct the `dataOptions` object correctly', function() {
        var deferred = $.Deferred();
        var spy = spyOn(module, 'query').and.returnValue(deferred.promise());
        spyOn($, 'publish');

        module.init();

        module.$input.val('test term');

        // No options
        module.runQuery();

        expect(module.query).toHaveBeenCalledWith({
          fee_scheme: 'fee_reform',
          search_offence: 'test term'
        });

        spy.calls.reset();

        // category_id
        module.runQuery({
          category_id: 2
        });

        expect(module.query).toHaveBeenCalledWith({
          fee_scheme: 'fee_reform',
          search_offence: 'test term',
          category_id: 2
        });

        spy.calls.reset();

        // band_id
        module.runQuery({
          band_id: 22,
          category_id: 99
        });

        expect(module.query).toHaveBeenCalledWith({
          fee_scheme: 'fee_reform',
          search_offence: 'test term',
          band_id: 22,
          category_id: 99
        });
      });

      it('should show the `clear search` link', function() {
        var deferred = $.Deferred();
        var spy = spyOn(module, 'query').and.returnValue(deferred.promise());
        spyOn($, 'publish');

        module.init();

        spyOn(module.$clear, 'show').and.callThrough();

        module.runQuery();

        module.query().then(function() {
          expect(module.$clear.show).toHaveBeenCalled()
        });

        deferred.resolve({});
      });

      it('should publish the search results', function() {
        var deferred = $.Deferred();
        var spy = spyOn(module, 'query').and.returnValue(deferred.promise());
        var fixtureData = {
          fee_scheme: "fee_reform",
          search_offence: "mur",
          results: [{
            result: 'one'
          }]
        }
        spyOn($, 'publish');

        module.init();

        module.runQuery();

        module.query().then(function() {
          expect($.publish).toHaveBeenCalledWith('/offence/search/results/', fixtureData)
        });

        deferred.resolve(fixtureData);
      });
    });

    describe('...trackUserInput', function() {
      it('should use `$.debounce`', function() {
        spyOn($, 'debounce');
        module.$input.val('mudr');

        module.init();

        // trigger keyup
        module.$input.trigger($.Event("keyup", {
          keyCode: 65
        }));

        expect($.debounce).toHaveBeenCalled();
      });
    });

    describe('...clearSearch', function() {
      it('should clear the `this.input` and `this.model` elements', function() {
        spyOn(module, 'clearSearch').and.callThrough();
        $('.fx-input').val('sample query');
        $('.fx-model').val('sample model');

        module.init();

        expect($(module.input).val()).toEqual('sample query');
        expect($(module.model).val()).toEqual('sample model');

        $('.fx-clear-search').trigger('click');

        expect($(module.input).val()).toEqual('');
        expect($(module.model).val()).toEqual('');

      });

      it('should `$.publish` the clear event', function() {
        spyOn($, 'publish')
        module.init();

        $('.fx-clear-search').trigger('click');
        expect($.publish).toHaveBeenCalledWith('/offence/search/clear/');
      });
    });

  });
});
