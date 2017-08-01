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
    order: [
      [5, 'asc']
    ],
    processing: true,
    dom: '<"form-row"<"column-one-half"f><"column-one-half"i>>t<"grid-row"<"column-one-half"l><"column-one-half"p>>', // tdd
    rowId: 'id',
    language: {
      loadingRecords: "Please wait - loading...",
      info: "Showing _START_ to _END_ of _TOTAL_ entries",
      lengthMenu: "Claims per page: _MENU_",
      infoFiltered: ""
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
      checkboxes: {
        selectRow: true,
        selectAllPages: false
      }
    }, {
      targets: 1,
      data: null,
      render: function(data, type, full) {
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
      render: {
        _: 'case_type',
        filter: 'case_type',
        display: function(data, type, full) {
          return data.case_type + '<br/><span class="state-display">' + data.state_display + '</span>';
        }
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
        filter: 'total',
        display: 'total_display'
      }
    }]
  },

  init: function() {
    this.$el = $('#dtAllocation');

    this.searchConfig.key = $('#api-key').data('api-key');

    // http://localhost:3001/api/search/unallocated?api_key=bbef1c5f-0ded-43d2-8d53-5a6358659dac&scheme=agfs
    this.options.ajax.url = '/api/search/unallocated?api_key={0}&scheme={1}'.supplant([
      this.searchConfig.key,
      this.searchConfig.scheme
    ]);

    this.dataTable = moj.Modules.DataTables._init(this.options, '#dtAllocation');

    // :(
    $('#dtAllocation_filter').find('input').addClass('form-control');


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
        return self.searchConfig.task === 'disk_evidence' ? rowData.filter.disk_evidence : rowData.filter.disk_evidence ? false : true;
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

    $.subscribe('/general/change/', function() {
      console.log('GENERIC Change');
      // self.clearFilter();
    });

    $.subscribe('/general/clear-filters/', function() {
      console.log('CLEAR ALL THE FILTERS');
      self.clearFilter();
    });

    $('.allocation-submit').on('click', function(e) {
      e.preventDefault();
      // table.rows({order:'current', filter:'applied'}).data({}).splice(0,50)

      var filters,
        isSelected,
        data,
        quantity_to_allocate,
        allocation_case_worker_id;

      quantity_to_allocate = $('#quantity_to_allocate').val();

      allocation_case_worker_id = $('#allocation_case_worker_id').val();



      if (!allocation_case_worker_id) {
        console.log('No Caseworker selected');
      }

      isSelected = self.dataTable.rows({
        filter: 'applied',
        search: 'applied',
        selected: true
      }).data().length;

      filters = {
        order: 'current',
        filter: 'applied',
        search: 'applied'
      };





      if (!!isSelected) {
        filters.selected = true;
      }

      // get the raw data object
      data = self.dataTable.rows(filters);
      // var sel = self.dataTable.rows({order:'current', filter:'applied', search:'applied', selected:true}).data().splice(0,25);

      window._data = data.pluck('id');


      // if(parseInt(quantity_to_allocate, 10) >= 1){
      //   console.log('CHOP CHOPS', parseInt(quantity_to_allocate, 10));
      //   data = data.splice(0,parseInt(quantity_to_allocate, 10));
      // }

      // console.log(data);
      // var deleteArr = [];
      // data = data.map(function(obj){
      //   deleteArr.push(obj.case_number);
      //   return obj.id;
      // });

      // console.log(data, deleteArr);


      console.log({
        authenticity_token: $("input[name='authenticity_token']").val(),
        quantity_to_allocate: quantity_to_allocate,
        'allocation[case_worker_id]': allocation_case_worker_id,
        commit: 'Allocate',
        'allocation[claim_ids][]': data.ids()
      });
      // $.ajax({
      //   url: '/case_workers/admin/allocations',
      //   method: 'POST',
      //   data: {
      //     authenticity_token: $("input[name='authenticity_token']").val(),
      //     quantity_to_allocate: 1,
      //     'allocation[case_worker_id]': 2,
      //     commit: 'Allocate'
      //   }
      // })
    });
  },

  tableDraw: function(data) {
    this
      .dataTable
      .draw();
  },

  clearCheckboxes: function() {
    console.log('clearCheckboxes');
    this.dataTable
      .column(0)
      .checkboxes
      .select(false);
  },

  clearSearchConfig: function() {
    console.log('clearSearchConfig');
    this.searchConfig = $.extend({}, {
      key: null,
      scheme: 'agfs',
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

  // Reload the data
  reloadScheme: function() {
    console.log('RELOAD');

    return this.dataTable.ajax.url('/assets/agfs.data.json'.supplant([this.searchConfig.key, this.searchConfig.scheme, this.searchConfig.defaultLimit])).load();
    // return this.dataTable.ajax.url('/api/search/unallocated?api_key={0}&scheme={1}&limit={2}'.supplant([this.searchConfig.key, this.searchConfig.scheme, this.searchConfig.defaultLimit])).load();
  }
}