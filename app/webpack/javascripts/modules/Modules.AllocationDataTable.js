/**
 * Allocation Controller
 * @type {Object}
 */
moj.Modules.AllocationDataTable = {
  // quick allocate
  defaultAllocationLimit: 25,

  // default scheme loaded via AJAX
  defaultScheme: 'agfs',

  // rarely used - a fallback to stop
  // accidental bulk allocation
  maxAllocationLimit: 100,

  // short cuts to UI elements
  ui: {
    $submit: null,
    $notificationMsg: null
  },

  // Filter / Search data object
  // This object and the state of it is what drives
  // the filters and search. Check tests for examples.
  //
  // You can manipulate this object by publishing events
  // and pass in settings / changes
  //
  // see: module-allocationDataTables_spec.js
  searchConfig: {
    key: null,
    defaultLimit: 150,
    scheme: 'agfs',
    task: null,
    valueBands: {
      min: null,
      max: null
    }
  },

  // DataTables options object
  // See: https://datatables.net/reference/option/
  // => https://datatables.net/reference/
  options: {

    // default order settings
    // =>/option/order
    order: [
      [5, 'asc']
    ],
    // row callback to add injection errors
    createdRow: function (row, data, index) {
      $(row).addClass('govuk-table__row')
      //  Add data row for responsive table label
      $(row).find('td').eq(0).attr('data-label', 'Select claim')
      $(row).find('td').eq(1).attr('data-label', 'Case number')
      $(row).find('td').eq(2).attr('data-label', 'Court')
      $(row).find('td').eq(3).attr('data-label', 'Defendants')
      $(row).find('td').eq(4).attr('data-label', 'Type')
      $(row).find('td').eq(5).attr('data-label', 'Submitted')
      $(row).find('td').eq(6).attr('data-label', 'Total')

      $('td', row).addClass('govuk-table__cell')

      const showWarning = data.filter.injection_errored || data.filter.cav_warning || data.filter.clar_fees_warning || data.filter.additional_prep_fee_warning || data.filter.disk_evidence

      if (showWarning) {
        $('td', row).eq(1).append('<div class="error-message-container"></div>')

        if (data.filter.injection_errored) { $('td .error-message-container', row).append('<div class="error-message">' + data.injection_errors + '</div>') }
        if (data.filter.cav_warning) { $('td .error-message-container', row).append('<div class="error-message">Conference fees not injected</div>') }
        if (data.filter.clar_fees_warning) { $('td .error-message-container', row).append('<div class="error-message">Paper heavy case or unused materials fees not injected</div>') }
        if (data.filter.additional_prep_fee_warning) { $('td .error-message-container', row).append('<div class="error-message">Additional prep fee not injected</div>') }
        if (data.filter.disk_evidence) { $('td .error-message-container', row).append('<div class="error-message">Disk evidence</div>') }
      }

      return row
    },

    // processing indicator
    // =>/option/processing
    // NOTE:
    processing: true,

    // dom template with custom wrappers and structure
    // =>/options/dom
    dom: '<"govuk-grid-row"<"govuk-grid-column-one-half"<"govuk-form-group"f>><"govuk-grid-column-one-half"i>>rt<"govuk-grid-row govuk-!-margin-top-5"<"govuk-grid-column-one-third"<"govuk-form-group"l>><"govuk-grid-column-two-thirds"p>>',

    // rowId can be sourced from the row data
    rowId: 'id',

    // translations and custom text
    language: {
      loadingRecords: 'Table loading, please wait a moment.',
      zeroRecords: 'No matching records found. Try clearing your filter.',
      info: 'Showing _START_ to _END_ of _TOTAL_ entries',
      lengthMenu: 'Claims per page: _MENU_',
      emptyTable: '',
      infoFiltered: '',
      processing: '',
      paginate: {
        previous: 'Previous',
        next: 'Next'
      }
    },
    initComplete: function (settings, json) {
      $('.app-jq-datatable tbody').addClass('govuk-table__body')
      // block the row highlight from happening
      // when a link is clicked
      $('.app-jq-datatable tbody tr').on('click', 'a', function (e) {
        e.stopImmediatePropagation()
      })
    },
    // $.ajax config object
    // https://datatables.net/reference/option/ajax
    // The url is set during the init procedures
    ajax: {
      url: '',

      // important to change this vlaue  accordingly
      // if the data structure changes
      dataSrc: ''
    },

    // Select multiple rows
    select: {
      style: 'multi'
    },

    // A definition to discribe each column in the table
    // See: =>/option/columnDefs
    columnDefs: [{
      targets: 0,
      data: 'id',
      checkboxes: {
        selectRow: true,
        selectAllPages: false
      },
      render: function (data, type, row) {
        return '<div class="govuk-form-group">' +
                '<div class="govuk-checkboxes govuk-checkboxes--small" data-module="govuk-checkboxes">' +
                '<div class="govuk-checkboxes__item">' +
                '<input class="govuk-checkboxes__input dt-checkboxes" type="checkbox" value="" name="claim-' + data + '" id="claim-' + data + '">' +
                '<label class="govuk-label govuk-checkboxes__label" for="claim-' + data + '">' +
                '<span class="govuk-visually-hidden">Select case ' + row.case_number + '</span>' +
                '</label>' +
                '</div>' +
                '</div>' +
                '</div>'
      }
    }, {
      targets: 1,
      data: null,
      render: function (data, type, full) {
        return '<span class="js-test-case-number"><a aria-label="View Claim, Case number: ' + data.case_number + '" href="/case_workers/claims/' + data.id + '">' + data.case_number + '</a></span>'
      }

    }, {
      targets: 2,
      data: 'court_name'
    }, {
      targets: 3,
      data: 'defendants'
    }, {
      targets: 4,
      data: null,
      render: function (data, type, full) {
        return data.case_type + '<br/><span class="state-display">' + data.state_display + '</span>'
      }
    }, {
      targets: 5,
      data: null,
      render: {
        _: 'last_submitted_at',
        sort: 'last_submitted_at',
        filter: 'last_submitted_at_display',
        display: 'last_submitted_at_display'
      }
    }, {
      targets: 6,
      data: null,
      render: {
        _: 'total',
        sort: 'total',
        filter: 'total_display',
        display: 'total_display'
      }
    }]
  },

  init: function () {
    this.$el = $('.app-jq-datatable')
    this.ui.$submit = $('.allocation-submit')
    this.ui.$notificationMsg = $('#allocation .govuk-notification-banner')

    this.searchConfig.key = $('#api-key').data('api-key')

    // Get the selected value and update the URL
    this.setAjaxURL(moj.Modules.AllocationScheme.selectedValue())
    this.dataTable = moj.Modules.DataTables._init(this.options, '.app-jq-datatable')

    // :(
    $('.dt-search').find('input[type=search]').addClass('govuk-input govuk-!-width-three-quarters')
    $('.dt-length').find('select').addClass('govuk-select')

    // circumvent GOVUK radio rule "Do not pre-select radio options"
    // plugin requires a default scheme to be set
    $('.js-allocation-page #scheme-agfs-field').prop('checked', true)

    this.bindEvents()
    this.registerCustomSearch()
  },

  /**
   * Update the URL for the AJAX requests
   * @param {String} scheme 'agfs' or 'lgfs'
   * return {String} the URL string with supplemented values
   */
  setAjaxURL: function (scheme) {
    this.searchConfig.scheme = scheme || this.defaultScheme
    this.options.ajax.url = '/api/search/unallocated?api_key={0}&scheme={1}'.supplant([
      this.searchConfig.key,
      this.searchConfig.scheme
    ])
    return this.options.ajax.url
  },
  /**
   * Check if there are any rows selected
   * @return {int} will return 0 or a positive int of the number
   * of rows selected.
   */
  itemsSelected: function () {
    return this.dataTable.column(0).checkboxes.selected().length
  },

  /**
   * DataTables custom search functions
   * - Task filter
   *   This method will filter results by selected task
   *   NOTE: claims with disk evidence will be excluded
   *         from results. Use the specific filter
   *
   * - Value Bands filter
   *   This method applies a integer range filter
   */
  registerCustomSearch: function () {
    const self = this

    // TASK FILTERS
    $.fn.dataTable.ext.search.push(function (settings, searchData, index, rowData, counter) {
      // Return true if task is undefined.
      if (!self.searchConfig.task) {
        return true
      }

      // Here we check if the row belongs in the results
      if (rowData.filter[self.searchConfig.task]) {
        // The row is included in the results but we filter out any from
        // this subset that have disk evidence as `true`
        //
        // If the task is the `Disk Evidence` one - we simply return the
        // `filter.disk_evidence` value
        return self.searchConfig.task === 'disk_evidence' ? rowData.filter.disk_evidence : !rowData.filter.disk_evidence
      }

      // The row does not meet the task filter
      // and is excluded from the results
      return false
    })

    // VALUE BAND FILTER
    $.fn.dataTable.ext.search.push(function (settings, searchData, index, rowData, counter) {
      const min = parseInt(self.searchConfig.valueBands.min, 10)
      const max = parseInt(self.searchConfig.valueBands.max, 10)
      const claimAmount = parseFloat(rowData.total) || 0 // use data for the claimAmount column

      if ((isNaN(min) && isNaN(max)) ||
        (isNaN(min) && claimAmount <= max) ||
        (min <= claimAmount && isNaN(max)) ||
        (min <= claimAmount && claimAmount <= max)) {
        return true
      }
      return false
    })
  },

  bindEvents: function () {
    const self = this

    // Clear the table before an AJAX call
    this.$el.on('preXhr.dt', function () {
      self.dataTable.clear().draw('page')
    })

    // Subscribe to the schene change
    // event and reload the data
    $.subscribe('/scheme/change/', function (e, data) {
      // update the scheme
      self.searchConfig.scheme = data.scheme
      self.clearFilter()
      self.reloadScheme(data)
    })

    // EVENT: Clear all filters & reset table
    $.subscribe('/filter/clearAll', function (e, data) {
      self.clearFilter(e, data)
    })

    // EVENT: Task filter
    $.subscribe('/filter/filterAGFS/', function (e, data) {
      self.searchConfig.task = data.data
      self.clearCheckboxes()
      self.tableDraw()
    })

    $.subscribe('/filter/filterLGFS/', function (e, data) {
      self.searchConfig.task = data.data
      self.clearCheckboxes()
      self.tableDraw()
    })

    // EVENT: Value band Filter
    $.subscribe('/filter/filterValue/', function (e, data) {
      const valueSelected = data.data.split('|')
      self.searchConfig.valueBands = {}
      valueSelected.forEach(function (value) {
        self.searchConfig.valueBands[value.split(':')[0]] = value.split(':')[1]
      })
      self.clearCheckboxes()
      self.tableDraw()
    })

    // EVENT: General clear filter
    $.subscribe('/general/clear-filters/', function () {
      self.clearFilter()
    })

    // EVENT: Allocate claims
    $('.allocation-submit').on('click', function (e) {
      self.ui.$notificationMsg.removeClass('govuk-!-display-none govuk-notification-banner--error govuk-notification-banner--success')
      self.ui.$notificationMsg.find('.govuk-notification-banner__heading').html('Allocating.. please wait a moment..')

      e.preventDefault()
      self.ui.$submit.prop('disabled', true)

      const quantityToAllocate = $('#quantity-to-allocate-field').val() || false

      const allocationCaseWorkerId = $('#allocation-case-worker-id-field-select').val()

      if (!allocationCaseWorkerId) {
        $.publish('/allocation/error/', {
          msg: 'Select a case worker.'
        })
        return
      }

      const filters = {
        order: 'current',
        filter: 'applied',
        search: 'applied'
      }

      if (self.itemsSelected() && !quantityToAllocate) {
        filters.selected = true
      }

      // get the raw data object
      const data = self.dataTable.rows(filters).data().splice(0, quantityToAllocate || (self.itemsSelected() ? self.maxAllocationLimit : self.defaultAllocationLimit)).map(function (obj) {
        return obj.id
      }).join(',')

      $.ajax({
        url: '/api/case_workers/allocate',
        method: 'POST',
        data: {
          api_key: self.searchConfig.key,
          case_worker_id: allocationCaseWorkerId,
          claim_ids: data
        }
      }).done(function (result) {
        self.ui.$notificationMsg.removeClass('govuk-!-display-none govuk-notification-banner--error')
        self.ui.$notificationMsg.addClass('govuk-notification-banner--success')
        self.ui.$notificationMsg.find('.govuk-notification-banner__heading').text(result.allocated_claims.length + ' claims have been allocated to ' + $('#allocation-case-worker-id-field').val())

        self.reloadScheme({
          scheme: self.searchConfig.scheme
        })
      }).fail(function (result) {
        self.ui.$notificationMsg.removeClass('govuk-!-display-none govuk-notification-banner--success')
        self.ui.$notificationMsg.addClass('govuk-notification-banner--error')
        if (result.status === 422) {
          return self.ui.$notificationMsg.find('.govuk-notification-banner__heading').html('Unable to allocate claim')
        }
        self.ui.$notificationMsg.find('.govuk-notification-banner__heading').html(result.responseJSON.errors.join(''))
      }).always(function () {
        self.ui.$submit.prop('disabled', false)
      })
    })

    // EVENT: Clear selected checkboxes on search
    self.dataTable.on('search.dt', function () {
      if ($('.app-jq-datatable thead input').prop('checked')) {
        self.clearCheckboxes()
      }
    })
  },

  // API: draw table
  tableDraw: function (data) {
    this
      .dataTable
      .draw()
  },

  // API: clear check boxes
  clearCheckboxes: function () {
    this.dataTable
      .column(0)
      .checkboxes
      .select(false)
  },

  // API: clear search config state
  clearSearchConfig: function () {
    this.searchConfig = $.extend({}, this.searchConfig, {
      task: null,
      valueBands: {
        min: null,
        max: null
      }
    })
  },

  // Wrapper to clear search & filters
  clearFilter: function (e, data) {
    this.clearCheckboxes()
    this.clearSearchConfig()
    this.dataTable
      .search('')
      .columns()
      .search('')
      .draw()
  },

  /**
   * Reload the data
   * This method will regenerate the URL before each use
   */
  reloadScheme: function (data) {
    this.dataTable.ajax.url(this.setAjaxURL(data.scheme))
    return this.dataTable.ajax.reload()
  }
}
