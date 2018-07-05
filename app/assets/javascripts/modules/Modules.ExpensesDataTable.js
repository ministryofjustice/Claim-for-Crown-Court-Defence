/**
 * Expenses data table Controller
 * @type {Object}
 */
moj.Modules.ExpensesDataTable = {
  el: '.expenses-data-table',

  // DataTables options object
  // See: https://datatables.net/reference/option/
  // => https://datatables.net/reference/
  options: {
    info: false,
    paging: false,
    searching: false,

    // by default orders by
    // type of expense (index 0) asc
    // and date of expense (index 3) asc
    order: [
      [0, 'asc'], [3, 'asc']
    ],

    columnDefs: [
      { targets: 2, orderable: false }
    ]
  },

  init: function() {
    this.$el = $(this.el);
    this.dataTable = moj.Modules.DataTables._init(this.options, this.el);
    this.bindEvents();
  },

  bindEvents: function() {
    var self = this;
    self.$el.on('preDraw.dt', function(){
      self.setOrder();
    });
  },

  setOrder: function() {
    var order = this.dataTable.order();
    var columnIndex = order[0][0];
    var direction = order[0][1];
    // this check is to ensure only type of expense (index 0)
    // and reason for travel (index 1) have secondary order column
    // set to date of expense (index 3) as the current configuration
    // for columnDefs does not support setting sorting direction
    if(columnIndex === 0 || columnIndex === 1) {
      this.dataTable.order([columnIndex, direction], [3, 'asc']);
    }
    if(columnIndex === 3) {
      this.dataTable.order([columnIndex, direction], [0, 'asc'], [1, 'asc']);
    }
  }
};
