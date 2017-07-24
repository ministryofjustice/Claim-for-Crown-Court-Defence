moj.Modules.AllocationDataTable = {
  filterConfig: {
    tasks: {
      all: {
        col: 0,
        val: ''
      },
      fixed_fee: {

      },
      cracked: {},
      trial: {},
      guilty_plea: {},
      redetermination: {},
      awaiting_written_reasons: {}
    }
  },
  options: {
    // dom: '<"top1"f><"top2"li>rt<"bottom"ip>', // tdd
    dom: '<"grid-row"<"column-one-half"f><"column-one-half"i>>t<"grid-row"<"column-one-half"l><"column-one-half"p>>', // tdd
    language: {
      loadingRecords: "Please wait - loading..."
    },
    ajax: {
      url: '/api/search/unallocated?api_key=bbef1c5f-0ded-43d2-8d53-5a6358659dac&scheme=agfs&limit=50',
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
        return "<a href='#noop'>" + data.case_number + "</a>";
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
    this.dataTable = moj.Modules.DataTables.init(this.options, '#dtAllocation');
    this.$el = $('#dtAllocation');

    $('#dtAllocation_length').find('select').addClass('form-control');
    this.bindEvents();
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
      self.reloadScheme(data.scheme);
    });

    $.subscribe('/filter/change/', function(e, data) {
      self.search(e, data);
    });

    $.subscribe('/filter/clearAll', function(e, data) {
      self.clearFilter(e, data)
    });

    $.subscribe('/filter/tasks/', function(e, data){
      console.log('LISTEN', e, data);
    });

  },
  search: function(e, data) {
    var val = $.fn.dataTable.util.escapeRegex(data.val);

    this.dataTable
      .columns(data.col)
      .search(data.val, true, false)
      .draw('page');

  },

  clearFilter: function(e, data) {
    this.dataTable
      .search('')
      .columns()
      .search('')
      .draw();
  },
  // Reload the data
  reloadScheme: function(scheme) {
    return this.dataTable.ajax.url('/api/search/unallocated?api_key=bbef1c5f-0ded-43d2-8d53-5a6358659dac&scheme=' + scheme + '&limit=50').load();
  }
}