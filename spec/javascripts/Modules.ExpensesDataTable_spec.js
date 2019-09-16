describe("Modules.ExpensesDataTable.js", function () {
  var module = moj.Modules.ExpensesDataTable;
  var options = module.options;

  it('...should exist', function () {
    expect(moj.Modules.ExpensesDataTable).toBeDefined();
  });

  describe('...Options', function () {
    it('...should have `info` disabled', function () {
      expect(options.info).toEqual(false);
    });

    it('...should have `paging` disabled', function () {
      expect(options.paging).toEqual(false);
    });

    it('...should have `searching` disabled', function () {
      expect(options.searching).toEqual(false);
    });

    it('...should have `order`', function () {
      expect(options.order).toEqual([
        [0, 'asc'],
        [3, 'asc']
      ]);
    });

    describe('...options.columnDefs', function () {
      var columnDefs = options.columnDefs;

      var getColsDefs = function (idx, prop) {
        prop = prop || "";
        return $.map([columnDefs[idx]], function (item) {
          return item[prop];
        });
      };

      var getColsDefsByTarget = function (target) {
        return $.map(columnDefs, function (item) {
          if (item.targets === target || 0) {
            return item;
          }
        })[0];
      };

      it('...should have `targets` defined', function () {
        expect(getColsDefs(0, "targets")).toEqual([0]);
        expect(getColsDefs(1, "targets")).toEqual([1]);
        expect(getColsDefs(2, "targets")).toEqual([2]);
        expect(getColsDefs(3, "targets")).toEqual([3]);
        expect(getColsDefs(4, "targets")).toEqual([4]);
        expect(getColsDefs(5, "targets")).toEqual([5]);
      });

      it('...should have orderable disabled for the details column', function () {
        expect(getColsDefsByTarget(0)).toEqual({
          targets: 0,
          width: "1%"
        });
        expect(getColsDefsByTarget(1)).toEqual({
          targets: 1,
          width: "20%"
        });
        expect(getColsDefsByTarget(2)).toEqual({
          targets: 2,
          orderable: false,
          width: "20%"
        });
        expect(getColsDefsByTarget(3)).toEqual({
          targets: 3,
          width: "1%"
        });
        expect(getColsDefsByTarget(4)).toEqual({
          targets: 4,
          width: "1%"
        });
        expect(getColsDefsByTarget(5)).toEqual({
          targets: 5,
          orderable: false,
          width: "1%"
        });
      });
    });
  });
});
