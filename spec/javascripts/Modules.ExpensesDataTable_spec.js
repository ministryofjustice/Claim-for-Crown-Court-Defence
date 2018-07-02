describe("Modules.ExpensesDataTable.js", function() {
  var module = moj.Modules.ExpensesDataTable;
  var options = module.options;

  it('...should exist', function() {
    expect(moj.Modules.ExpensesDataTable).toBeDefined();
  });

  describe('...Options', function() {
    it('...should have `info` disabled', function() {
      expect(options.info).toEqual(false);
    });

    it('...should have `paging` disabled', function() {
      expect(options.paging).toEqual(false);
    });

    it('...should have `searching` disabled', function() {
      expect(options.searching).toEqual(false);
    });

    it('...should have `order`', function() {
      expect(options.order).toEqual([
        [0, 'asc'],
        [3, 'asc']
      ]);
    });

    describe('...options.columnDefs', function() {
      var columnDefs = options.columnDefs;
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
        expect(getColsDefs("targets")).toEqual([2]);
      })

      it('...should have orderable disabled for the details column', function() {
        var result = getColsDefsByTarget(2);
        expect(result).toEqual({
          targets: 2,
          orderable: false
        })
      });
    });
  });
});
