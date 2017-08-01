describe("Modules.AllocationDataTable.js", function() {
  // tooooo long to type
  var defaults = moj.Modules.AllocationDataTable.options;

  it('...should exist', function() {
    expect(moj.Modules.AllocationDataTable).toBeDefined();
  });

  xit('...should have defaults set', function() {
    // dom:
    // defines the semantic structure of the table
    //
    // https://datatables.net/reference/option/dom
    // expect(defaults.dom).toEqual('<"top1"f><"top2"li>rt<"bottom"ip>');
    console.log('skipped');

    // ajax
    // The ajax obj is passed to jQuery.ajax()
    // https://datatables.net/reference/option/ajax
    // http://api.jquery.com/jQuery.ajax/
    expect(defaults.ajax).toEqual({
      url: '/api/search/unallocated?api_key={0}&scheme=agfs&limit=150',
      dataSrc: ''
    })

    // columnDefs:
    // https://datatables.net/reference/option/columnDefs
    // expect(defaults.columnDefs).toBeDefined();

    // columns:
    // https://datatables.net/reference/option/columns
    // For the JSON structure the API returns, the `columnDefs`
    // config is better suited.
    expect(defaults.columns).not.toBeDefined();
  })

  describe('...defaults.columnDefs', function() {
    var columnDefs = defaults.columnDefs;
    var getColsDefs = function(prop) {
      prop = prop || "";
      return $.map(columnDefs, function(item) {
        return item[prop];
      });
    }

    var getColsDefsByTarget = function(target) {
      return $.map(columnDefs, function(item) {
        if (item.targets === target || 0) {
          return item;
        }
      })[0];
    }

    it('...should have `targets` defined', function() {
      expect(getColsDefs("targets")).toEqual([0, 1, 2, 3, 4, 5, 6])
    })

    it('...should have `data` defined', function() {
      expect(getColsDefs("data")).toEqual(['id', 'court_name', 'defendants'])
    });

    describe('...columnDefs[total]', function() {

      it('...`render`', function() {
        var result = getColsDefsByTarget(6);
        expect(result).toEqual({
          targets: 6,
          data: null,
          render: {
            _: 'total',
            filter: 'total',
            display: 'total_display'
          }
        })
      });
    });

    describe('...columnDefs[last_submitted_at]', function() {
      var result = getColsDefsByTarget(5);

      it('...`render`', function() {
        expect(result.targets).toEqual(5);

        expect(result.data).toEqual(null);

        expect(result.render._).toEqual('last_submitted_at');
        expect(result.render.sort).toEqual('last_submitted_at');
        expect(result.render.filter).toEqual('last_submitted_at_display');
        expect(result.render.display).toEqual('last_submitted_at_display');
      });
    });
  });
});