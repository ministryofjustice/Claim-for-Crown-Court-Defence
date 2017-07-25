moj.Modules.AllocationDataTable = {
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
    // dom: '<"top1"f><"top2"li>rt<"bottom"ip>', // tdd
    order: [
      [5, 'asc']
    ],
    processing: true,
    dom: '<"grid-row"<"column-one-half"f><"column-one-half"i>>t<"grid-row"<"column-one-half"l><"column-one-half"p>>', // tdd
    language: {
      loadingRecords: "Please wait - loading..."
    },
    ajax: {
      url: null,
      dataSrc: ""
    },
    columnDefs: [{
      targets: 0,
      searchable: false,
      orderable: false,
      className: 'dt-body-center',
      render: function(data, type, full) {
        return '<input type="checkbox">';
      }
    }, {
      targets: 1,
      data: null,
      render: function(data, type, full) {
        return data.disk_evidence ? '<a href="#noop">' + data.case_number + '</a><br/><span class="disk-evidence">Disk evidence</span>' : '<a href="#noop">' + data.case_number + '</a>';
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
      render: {
        _: 'case_type',
        filter: 'case_type',
        display: function(data, type, full) {
          return data.case_type + '<br/><span>' + data.state_display + '</span>';
        }
      }
    }, {
      targets: 5,
      data: null,
      render: {
        _: 'last_submitted_at',
        filter: function(data) {
          return [data.case_type, data.state_display].join(', ');
        },
        display: function(data, type, full) {
          return data.last_submitted_at_display;
        }
      }
    }, {
      targets: 6,
      data: null,
      render: {
        _: 'total',
        filter: 'total',
        display: 'total_display'
      }
    }]
  },
  init: function() {
    this.$el = $('#dtAllocation');

    this.searchConfig.key = $('#api-key').data('api-key');
    this.options.ajax.url = '/api/search/unallocated?api_key={0}&scheme={1}&limit={2}'.supplant([this.searchConfig.key, this.searchConfig.scheme, this.searchConfig.defaultLimit]);

    this.dataTable = moj.Modules.DataTables.init(this.options, '#dtAllocation');

    // :(
    $('#dtAllocation_length').find('select').addClass('form-control');

    this.bindEvents();
    this.registerCustomSearch();

  },
  registerCustomSearch: function() {
    var self = this;

    // TASK FILTERS
    $.fn.dataTable.ext.search.push(function(settings, searchData, index, rowData, counter) {
      // Return true if task is undefined.
      if (!self.searchConfig.task) {
        return true;
      }

      // Apply the task filter
      if (rowData.filter[self.searchConfig.task]) {
        return true;
      }

      // Return false if fall through
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
      self.reloadScheme();
    });

    // EVENT: Clear all filters & reset table
    $.subscribe('/filter/clearAll', function(e, data) {
      self.clearFilter(e, data)
    });

    // EVENT: Task filter
    $.subscribe('/filter/tasks/', function(e, data) {
      self.searchConfig.task = data.data;
      self.tableDraw();
    });

    $.subscribe('/filter/filter_value_bands/', function(e, data) {
      var valueSelected = data.data.split('|');
      self.searchConfig.valueBands = {};
      valueSelected.forEach(function(data) {
        self.searchConfig.valueBands[data.split(':')[0]] = data.split(':')[1];
      });
      self.tableDraw();
    });

  },
  tableDraw: function(data) {
    this.dataTable
      .draw();
  },
  clearFilter: function(e, data) {
    this.dataTable
      .search('')
      .columns()
      .search('')
      .draw();
  },
  // Reload the data
  reloadScheme: function() {
    return this.dataTable.ajax.url('/api/search/unallocated?api_key={0}&scheme={1}&limit={2}'.supplant([this.searchConfig.key, this.searchConfig.scheme, this.searchConfig.defaultLimit])).load();
  }
}