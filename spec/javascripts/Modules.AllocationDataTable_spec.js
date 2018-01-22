describe("Modules.AllocationDataTable.js", function() {
  var domFixture = ['<div id="dtAllocation">',
    ' <button class="allocation-submit">submit</button>',
    ' <div class="notice-summary">Notice Summary</div>',
    ' <div class="error-summary">Error Summary</div>',
    ' <div id="api-key" data-api-key="abcABC">//</div>',
    '</div>'
  ].join('');

  // tooooo long to type
  var module = moj.Modules.AllocationDataTable;
  var options = module.options;

  it('...should exist', function() {
    expect(moj.Modules.AllocationDataTable).toBeDefined();
  });

  it('...should have options set', function() {
    // dom:
    // defines the semantic structure of the table
    //
    // https://datatables.net/reference/option/dom
    // expect(options.dom).toEqual('<"top1"f><"top2"li>rt<"bottom"ip>');



    // ajax
    // The ajax obj is passed to jQuery.ajax()
    // https://datatables.net/reference/option/ajax
    // http://api.jquery.com/jQuery.ajax/
    // expect(options.ajax).toEqual({
    //   url: '/api/search/unallocated?api_key={0}&scheme=agfs&limit=150',
    //   dataSrc: ''
    // })

    // columnDefs:
    // https://datatables.net/reference/option/columnDefs
    // expect(options.columnDefs).toBeDefined();

    // columns:
    // https://datatables.net/reference/option/columns
    // For the JSON structure the API returns, the `columnDefs`
    // config is better suited.
    expect(options.columns).not.toBeDefined();
  });

  it('...should have a `defaultAllocationLimit` set', function() {
    expect(module.defaultAllocationLimit).toEqual(25);
  });

  it('...should have a `defaultScheme` set', function() {
    expect(module.defaultScheme).toEqual('agfs');
  });

  describe('...Options', function() {

    it('...should have `order`', function() {
      expect(options.order).toEqual([
        [5, 'asc']
      ]);
    });

    it('...should have a `createdRow` callback defined', function() {
      expect(options.createdRow).toBeDefined();
      var row = $('<tr><td></td></tr>');
      var data = {
        "injection_errors": "I am an error",
        "filter": {
          "injection_errored": 1
        }
      }
      var output = options.createdRow(row, data)
      expect(output[0].outerHTML).toEqual('<tr class="error"><td><div class="error-message-container"><div class="error-message">I am an error</div></div></td></tr>')
    });

    it('...should have `processing`', function() {
      expect(options.processing).toEqual(true);
    });

    it('...should have `dom`', function() {
      expect(options.dom).toEqual('<"form-row"<"column-one-half"f><"column-one-half"i>>rt<"grid-row"<"column-one-third"l><"column-two-thirds"p>>');
    });

    it('...should have `rowId`', function() {
      expect(options.rowId).toEqual('id');
    });

    it('...should have `language`', function() {
      expect(options.language).toEqual({
        loadingRecords: "",
        zeroRecords: "No matching records found. Try clearing your filter.",
        info: "Showing _START_ to _END_ of _TOTAL_ entries",
        lengthMenu: "Claims per page: _MENU_",
        emptyTable: "",
        infoFiltered: "",
        processing: "Table loading, please wait a moment."
      })
    });

    it('...should have `ajax`', function() {
      expect(options.ajax).toEqual({
        url: '/api/search/unallocated?api_key={0}&scheme=agfs',
        dataSrc: '' // this is the important setting
      });
    });

    it('...should have `select`', function() {
      expect(options.select).toEqual({
        style: 'multi'
      });
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
              sort: 'total',
              filter: 'total_display',
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


  describe('...Methods', function() {
    xdescribe('...init', function() {

    });

    describe('...setAjaxURL', function() {
      beforeAll(function() {
        // mocking the API key on the page
        $('<div/>', {
          id: 'api-key',
          'data-api-key': '1234567890'
        }).appendTo('body');
      });

      afterAll(function() {
        $('#api-key').remove();
      });

      it('...should have access to String.prototype.supplant', function() {
        expect(String.prototype.supplant).toBeDefined();
      });

      it('...should exist', function() {
        expect(module.setAjaxURL).toBeDefined();
      });

      it('...should use `defaultScheme` as a fallback', function() {


        // call init again
        module.init();

        expect(module.options.ajax.url).toEqual('/api/search/unallocated?api_key=1234567890&scheme=agfs');

        module.setAjaxURL('abcd')

        expect(module.options.ajax.url).toEqual('/api/search/unallocated?api_key=1234567890&scheme=abcd');

        module.setAjaxURL()

        expect(module.options.ajax.url).toEqual('/api/search/unallocated?api_key=1234567890&scheme=agfs');
      });

      it('...should set the scheme as passed in', function() {

        module.setAjaxURL('abcd');

        expect(module.options.ajax.url).toEqual('/api/search/unallocated?api_key=1234567890&scheme=abcd');
      });

      it('...should return a string', function() {
        expect(typeof module.setAjaxURL()).toBe('string');
      });

    });

    xdescribe('...itemsSelected', function() {

    });

    xdescribe('...registerCustomSearch', function() {

    });

    xdescribe('...bindEvents', function() {

    });

  });

});