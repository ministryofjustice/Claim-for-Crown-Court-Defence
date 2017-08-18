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
    $msgSuccess: null,
    $msgFail: null
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

    // processing indicator
    // =>/option/processing
    // NOTE:
    processing: true,

    // dom template with custom wrappers and structure
    // =>/options/dom
    dom: '<"form-row"<"column-one-half"f><"column-one-half"i>>rt<"grid-row"<"column-one-third"l><"column-two-thirds"p>>',

    // rowId can be sourced from the row data
    rowId: 'id',

    // translations and custom text
    language: {
      loadingRecords: "",
      zeroRecords: "No matching records found. Try clearing your filter.",
      info: "Showing _START_ to _END_ of _TOTAL_ entries",
      lengthMenu: "Claims per page: _MENU_",
      emptyTable: "",
      infoFiltered: "",
      processing: "Table loading, please wait a moment."
    },
    initComplete: function(settings, json) {
      // block the row highlight from happening
      // when a link is clicked
      $('#dtAllocation tbody tr').on('click', 'a', function(e){
        e.stopImmediatePropagation();
      });
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
      width: '5%',
      checkboxes: {
        selectRow: true,
        selectAllPages: false
      }
    }, {
      targets: 1,
      data: null,
      render: function(data, type, full) {
        return data.filter.disk_evidence ? '<a href="/case_workers/claims/'+ data.id +'">' + data.case_number + '</a><br/><span class="disk-evidence">Disk evidence</span>' : '<a href="/case_workers/claims/'+ data.id +'">' + data.case_number + '</a>';
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
      render: function(data, type, full) {
        return data.case_type + '<br/><span class="state-display">' + data.state_display + '</span>';
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

  init: function() {
    this.$el = $('#dtAllocation');
    this.ui.$submit = $('.allocation-submit');
    this.ui.$msgSuccess = $('.notice-summary');
    this.ui.$msgFail = $('.error-summary');

    this.searchConfig.key = $('#api-key').data('api-key');

    this.setAjaxURL();
    this.dataTable = moj.Modules.DataTables._init(this.options, '#dtAllocation');

    // :(
    $('#dtAllocation_filter').find('input').addClass('form-control');

    this.bindEvents();
    this.registerCustomSearch();
  },

  /**
   * Update the URL for the AJAX requests
   * @param {String} scheme 'agfs' or 'lgfs'
   * return {String} the URL string with supplemented values
   */
  setAjaxURL: function(scheme) {
    this.searchConfig.scheme = scheme || this.defaultScheme;

    return this.options.ajax.url = '/api/search/unallocated?api_key={0}&scheme={1}'.supplant([
      this.searchConfig.key,
      this.searchConfig.scheme
    ]);
  },
  /**
   * Check if there are any rows selected
   * @return {int} will return 0 or a positive int of the number
   * of rows selected.
   */
  itemsSelected: function() {
    return this.dataTable.column(0).checkboxes.selected().length;
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
  registerCustomSearch: function() {
    var self = this;

    // TASK FILTERS
    $.fn.dataTable.ext.search.push(function(settings, searchData, index, rowData, counter) {
      // Return true if task is undefined.
      if (!self.searchConfig.task) {
        return true;
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
      return false;
    });

    // VALUE BAND FILTER
    $.fn.dataTable.ext.search.push(function(settings, searchData, index, rowData, counter) {
      var min = parseInt(self.searchConfig.valueBands.min, 10);
      var max = parseInt(self.searchConfig.valueBands.max, 10);
      var claimAmount = parseFloat(rowData.total) || 0; // use data for the claimAmount column


      if ((isNaN(min) && isNaN(max)) ||
        (isNaN(min) && claimAmount <= max) ||
        (min <= claimAmount && isNaN(max)) ||
        (min <= claimAmount && claimAmount <= max)) {
        return true;
      }
      return false;
    });
  },

  bindEvents: function() {
    var self = this;

    // Clear the table before an AJAX call
    this.$el.on('preXhr.dt', function() {
      self.dataTable.clear().draw('page');
    });

    // Subscribe to the schene change
    // event and reload the data
    $.subscribe('/scheme/change/', function(e, data) {
      // update the scheme
      self.searchConfig.scheme = data.scheme;
      self.clearFilter();
      self.reloadScheme(data);
    });

    // EVENT: Clear all filters & reset table
    $.subscribe('/filter/clearAll', function(e, data) {
      self.clearFilter(e, data)
    });

    // EVENT: Task filter
    $.subscribe('/filter/tasks/', function(e, data) {
      self.searchConfig.task = data.data;
      self.clearCheckboxes();
      self.tableDraw();
    });

    // EVENT: Value band Filter
    $.subscribe('/filter/filter_value_bands/', function(e, data) {
      var valueSelected = data.data.split('|');
      self.searchConfig.valueBands = {};
      valueSelected.forEach(function(data) {
        self.searchConfig.valueBands[data.split(':')[0]] = data.split(':')[1];
      });
      self.clearCheckboxes();
      self.tableDraw();
    });

    // EVENT: General clear filter
    $.subscribe('/general/clear-filters/', function() {
      self.clearFilter();
    });

    // EVENT: Allocate claims
    $('.allocation-submit').on('click', function(e) {

      self.ui.$msgFail.find('span').html();
      self.ui.$msgSuccess.hide();

      self.ui.$msgSuccess.find('span').html('Allocating.. please wait a moment..');
      self.ui.$msgSuccess.show();

      e.preventDefault();
      self.ui.$submit.prop('disabled', true);
      var filters,
        data,
        quantity_to_allocate,
        allocation_case_worker_id;

      quantity_to_allocate = $('#quantity_to_allocate').val() || false;

      allocation_case_worker_id = $('#allocation_case_worker_id').val();

      if (!allocation_case_worker_id) {
        // console.log('No Caseworker selected');
        $.publish('/allocation/error/', {
          msg: 'Please select a case worker.'
        })
        return;
      }

      filters = {
        order: 'current',
        filter: 'applied',
        search: 'applied'
      };

      if (self.itemsSelected() && !quantity_to_allocate) {
        filters.selected = true;
      }

      // get the raw data object
      data = self.dataTable.rows(filters).data().splice(0, quantity_to_allocate || (self.itemsSelected() ? self.maxAllocationLimit : self.defaultAllocationLimit)).map(function(obj) {
        return obj.id;
      }).join(',');



      $.ajax({
        url: '/api/case_workers/allocate',
        method: 'POST',
        data: {
          api_key: self.searchConfig.key,
          case_worker_id: allocation_case_worker_id,
          claim_ids: data
        }
      }).success(function(data) {
        self.ui.$msgFail.hide();
        self.ui.$msgSuccess.find('span').html(data.allocated_claims.length + ' claims have been allocated to ' + $('#allocation_case_worker_id_input').val());
        self.ui.$msgSuccess.show();
        self.reloadScheme({
          scheme: self.searchConfig.scheme
        });
      }).error(function(data) {
        self.ui.$msgSuccess.hide();
        self.ui.$msgFail.find('span').html(data.responseJSON.errors.join(''));
        self.ui.$msgFail.show();
      }).always(function() {
        self.ui.$submit.prop('disabled', false);
      });
    });

    // EVENT: Clear selected checkboxes on search
    self.dataTable.on('search.dt', function() {
      if ($('#dtAllocation thead input').prop('checked')) {
        self.clearCheckboxes();
      }
    });
  },

  // API: draw table
  tableDraw: function(data) {
    this
      .dataTable
      .draw();
  },

  // API: clear check boxes
  clearCheckboxes: function() {
    this.dataTable
      .column(0)
      .checkboxes
      .select(false);
  },

  // API: clear search config state
  clearSearchConfig: function() {
    this.searchConfig = $.extend({}, this.searchConfig, {
      task: null,
      valueBands: {
        min: null,
        max: null
      }
    });
  },

  // Wrapper to clear search & filters
  clearFilter: function(e, data) {
    this.clearCheckboxes();
    this.clearSearchConfig();
    this.dataTable
      .search('')
      .columns()
      .search('')
      .draw();
  },

  /**
   * Reload the data
   * This method will regenerate the URL before each use
   */
  reloadScheme: function(data) {
    this.dataTable.ajax.url(this.setAjaxURL(data.scheme));
    return this.dataTable.ajax.reload();
  }
}