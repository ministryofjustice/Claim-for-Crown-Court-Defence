moj.Modules.AllocationDataTable = {
  options: {
    // dom: '<"top1"f><"top2"li>rt<"bottom"ip>', // tdd
    dom: 'fitrlp', // tdd
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
  },

  // Reload the data
  reloadScheme: function(scheme) {
    return this.dataTable.ajax.url('/api/search/unallocated?api_key=bbef1c5f-0ded-43d2-8d53-5a6358659dac&scheme=' + scheme + '&limit=50').load();
  }
}