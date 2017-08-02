moj.Modules.AllocationDataTable = {
  defaultAllocationLimit: 25,
  defaultScheme: 'agfs',
  maxAllocationLimit: 100,
  ui: {
    $submit: $('.allocation-submit')
  },
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
  options: {
    order: [
      [5, 'asc']
    ],
    processing: true,
    dom: '<"form-row"<"column-one-half"f><"column-one-half"i>>rt<"grid-row"<"column-one-half"l><"column-one-half"p>>', // tdd
    rowId: 'id',
    language: {
      loadingRecords: "",
      zeroRecords: "No matching records found. Try clearing your filter.",
      info: "Showing _START_ to _END_ of _TOTAL_ entries",
      lengthMenu: "Claims per page: _MENU_",
      emptyTable: "",
      infoFiltered: "",
      processing: "Table loading, please wait a moment."
    },
    ajax: {
      url: '/assets/agfs.data.json',
      dataSrc: ''
    },
    select: {
      style: 'multi'
    },
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
        // No link string
        return data.filter.disk_evidence ? data.case_number + '<br/><span class="disk-evidence">Disk evidence</span>' : data.case_number;
        //return data.filter.disk_evidence ? '<a href="#noop">' + data.case_number + '</a><br/><span class="disk-evidence">Disk evidence</span>' : '<a href="#noop">' + data.case_number + '</a>';
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

    this.searchConfig.key = $('#api-key').data('api-key');

    // http://localhost:3001/api/search/unallocated?api_key=bbef1c5f-0ded-43d2-8d53-5a6358659dac&scheme=agfs

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

    $.subscribe('/filter/filter_value_bands/', function(e, data) {
      var valueSelected = data.data.split('|');
      self.searchConfig.valueBands = {};
      valueSelected.forEach(function(data) {
        self.searchConfig.valueBands[data.split(':')[0]] = data.split(':')[1];
      });
      self.clearCheckboxes();
      self.tableDraw();
    });

    $.subscribe('/general/change/', function() {
      // console.log('GENERIC Change IS THIS USEFUL');
      // self.clearFilter();
    });

    $.subscribe('/general/clear-filters/', function() {
      self.clearFilter();
    });

    $('.allocation-submit').on('click', function(e) {
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
      }).success(function() {
        self.reloadScheme({
          scheme: self.searchConfig.scheme
        });
      }).error(function() {
        console.log('ERRRRORRR');
      }).complete(function() {
        self.ui.$submit.prop('disabled', false);
      });
    });

    self.dataTable.on('search.dt', function() {
      if ($('#dtAllocation thead input').prop('checked')) {
        self.clearCheckboxes();
      }
    });
  },

  tableDraw: function(data) {
    this
      .dataTable
      .draw();
  },

  clearCheckboxes: function() {
    // console.log('clearCheckboxes');
    this.dataTable
      .column(0)
      .checkboxes
      .select(false);
  },

  clearSearchConfig: function() {
    // console.log('clearSearchConfig');
    this.searchConfig = $.extend({}, this.searchConfig, {
      task: null,
      valueBands: {
        min: null,
        max: null
      }
    });
  },

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
   * [reloadScheme description]
   * @param  {[type]} data [description]
   * @return {[type]}      [description]
   */
  reloadScheme: function(data) {
    this.dataTable.ajax.url(this.setAjaxURL(data.scheme));
    return this.dataTable.ajax.reload();
  }
}



