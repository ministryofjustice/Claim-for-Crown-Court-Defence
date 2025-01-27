describe('Modules.AllocationDataTable.js', function () {
  const module = moj.Modules.AllocationDataTable
  const options = module.options

  it('...should exist', function () {
    expect(module).toBeDefined()
  })

  it('...should have options set', function () {
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
    expect(options.columns).not.toBeDefined()
  })

  it('...should have a `defaultAllocationLimit` set', function () {
    expect(module.defaultAllocationLimit).toEqual(25)
  })

  it('...should have a `defaultScheme` set', function () {
    expect(module.defaultScheme).toEqual('agfs')
  })

  describe('...Options', function () {
    it('...should have `order`', function () {
      expect(options.order).toEqual([
        [5, 'asc']
      ])
    })

    it('...should have a `createdRow` callback defined', function () {
      expect(options.createdRow).toBeDefined()
      const row = $('<tr class="govuk-table__row error injection-error"><td data-label="Select claim" class="govuk-table__cell"></td></tr>')
      const data = {
        injection_errors: 'I am an error',
        filter: {
          injection_errored: 1
        }
      }
      const output = options.createdRow(row, data)
      expect(output[0].outerHTML).toEqual('<tr class="govuk-table__row error injection-error"><td data-label="Select claim" class="govuk-table__cell"><div class="error-message-container"><div class="error-message">I am an error</div></div></td></tr>')
    })

    it('...should have a `createdRow` callback defined for CAV warnings', function () {
      expect(options.createdRow).toBeDefined()
      const row = $('<tr class="govuk-table__row injection-warning"><td data-label="Select claim" class="govuk-table__cell"></td></tr>')
      const data = {
        filter: {
          cav_warning: 1
        }
      }
      const output = options.createdRow(row, data)
      expect(output[0].outerHTML).toEqual('<tr class="govuk-table__row injection-warning"><td data-label="Select claim" class="govuk-table__cell"><div class="warning-message-container"><div class="warning-message">Conference fees not injected</div></div></td></tr>')
    })

    it('...should have a `createdRow` callback defined for CLAR fee warnings', function () {
      expect(options.createdRow).toBeDefined()
      const row = $('<tr class="govuk-table__row injection-warning"><td data-label="Select claim" class="govuk-table__cell"></td></tr>')
      const data = {
        filter: {
          clar_fees_warning: 1
        }
      }
      const output = options.createdRow(row, data)
      expect(output[0].outerHTML).toEqual('<tr class="govuk-table__row injection-warning"><td data-label="Select claim" class="govuk-table__cell"><div class="warning-message-container"><div class="warning-message">Paper heavy case or unused materials fees not injected</div></div></td></tr>')
    })

    it('...should have a `createdRow` callback defined for Additional Prep fee warnings', function () {
      expect(options.createdRow).toBeDefined()
      const row = $('<tr class="govuk-table__row injection-warning"><td data-label="Select claim" class="govuk-table__cell"></td></tr>')
      const data = {
        filter: {
          additional_prep_fee_warning: 1
        }
      }
      const output = options.createdRow(row, data)
      expect(output[0].outerHTML).toEqual('<tr class="govuk-table__row injection-warning"><td data-label="Select claim" class="govuk-table__cell"><div class="warning-message-container"><div class="warning-message">Additional prep fee not injected</div></div></td></tr>')
    })

    it('...should have `processing`', function () {
      expect(options.processing).toEqual(true)
    })

    it('...should have `dom`', function () {
      expect(options.dom).toEqual('<"govuk-grid-row"<"govuk-grid-column-one-half"<"govuk-form-group"f>><"govuk-grid-column-one-half"i>>rt<"govuk-grid-row govuk-!-margin-top-5"<"govuk-grid-column-one-third"<"govuk-form-group"l>><"govuk-grid-column-two-thirds"p>>')
    })

    it('...should have `rowId`', function () {
      expect(options.rowId).toEqual('id')
    })

    it('...should have `language`', function () {
      expect(options.language).toEqual({
        loadingRecords: 'Table loading, please wait a moment.',
        zeroRecords: 'No matching records found. Try clearing your filter.',
        info: 'Showing _START_ to _END_ of _TOTAL_ entries',
        lengthMenu: 'Claims per page: _MENU_',
        emptyTable: '',
        infoFiltered: '',
        processing: '',
        paginate: { previous: 'Previous', next: 'Next' }
      })
    })

    it('...should have `ajax`', function () {
      module.init()
      expect(options.ajax).toEqual({
        url: '/api/search/unallocated?api_key={0}&scheme=agfs',
        dataSrc: '' // this is the important setting
      })
    })

    it('...should have `select`', function () {
      expect(options.select).toEqual({
        style: 'multi'
      })
    })

    describe('...options.columnDefs', function () {
      const columnDefs = options.columnDefs
      const getColsDefs = function (prop) {
        prop = prop || ''
        return $.map(columnDefs, function (item) {
          return item[prop]
        })
      }

      const getColsDefsByTarget = function (target) {
        return $.map(columnDefs, function (item) {
          if (item.targets === target || 0) {
            return item
          }
        })[0]
      }

      it('...should have `targets` defined', function () {
        expect(getColsDefs('targets')).toEqual([0, 1, 2, 3, 4, 5, 6])
      })

      it('...should have `data` defined', function () {
        expect(getColsDefs('data')).toEqual(['id', 'court_name', 'defendants'])
      })

      describe('...columnDefs[total]', function () {
        it('...`render`', function () {
          const result = getColsDefsByTarget(6)
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
        })
      })

      describe('...columnDefs[last_submitted_at]', function () {
        const result = getColsDefsByTarget(5)

        it('...`render`', function () {
          expect(result.targets).toEqual(5)

          expect(result.data).toEqual(null)

          expect(result.render._).toEqual('last_submitted_at')
          expect(result.render.sort).toEqual('last_submitted_at')
          expect(result.render.filter).toEqual('last_submitted_at_display')
          expect(result.render.display).toEqual('last_submitted_at_display')
        })
      })
    })
  })

  describe('...Methods', function () {
    describe('...init', function () {
      it('...should call `this.setAjaxURL`', function () {
        spyOn(module, 'setAjaxURL').and.callThrough()
        spyOn(moj.Modules.AllocationScheme, 'selectedValue').and.callThrough()

        module.init()

        expect(module.setAjaxURL).toHaveBeenCalled()
        expect(moj.Modules.AllocationScheme.selectedValue).toHaveBeenCalled()
      })
    })

    describe('...setAjaxURL', function () {
      beforeAll(function () {
        // mocking the API key on the page
        $('<div/>', {
          id: 'api-key',
          'data-api-key': '1234567890'
        }).appendTo('body')
      })

      beforeEach(function () {
        module.init()
      })

      afterAll(function () {
        $('#api-key').remove()
      })

      it('...should have access to String.prototype.supplant', function () {
        expect(String.prototype.supplant).toBeDefined()
      })

      it('...should exist', function () {
        expect(module.setAjaxURL).toBeDefined()
      })

      it('...should use `defaultScheme` as a fallback', function () {
        expect(options.ajax.url).toEqual('/api/search/unallocated?api_key=1234567890&scheme=agfs')

        module.setAjaxURL('abcd')

        expect(options.ajax.url).toEqual('/api/search/unallocated?api_key=1234567890&scheme=abcd')

        module.setAjaxURL()

        expect(options.ajax.url).toEqual('/api/search/unallocated?api_key=1234567890&scheme=agfs')
      })

      it('...should set the scheme as passed in', function () {
        module.setAjaxURL('abcd')

        expect(options.ajax.url).toEqual('/api/search/unallocated?api_key=1234567890&scheme=abcd')
      })

      it('...should return a string', function () {
        expect(typeof module.setAjaxURL()).toBe('string')
      })
    })
  })
})
