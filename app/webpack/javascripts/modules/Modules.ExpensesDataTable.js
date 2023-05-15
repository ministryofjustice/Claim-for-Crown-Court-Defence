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
    //date of expense (index 3) desc
    order: [
      [3, 'desc']
    ],
    columnDefs: [{
      targets: 0,
      width: '1%'
    },
    {
      targets: 1,
      width: '20%'
    }, {
      targets: 2,
      orderable: false,
      width: '20%'
    }, {
      targets: 3,
      width: '1%',
      type: 'date',
      render: function (data, type, row) {
        if (type === 'sort') {
          // Check for invalid dates before conversion
          if (!data || isNaN(parseDate(data, 'dd/mm/yyyy'))) {
            return '';
          }

          // Convert the valid date string to a sortable format (e.g., '2023-04-29')
          return formatDate(parseDate(data, 'dd/mm/yyyy'), 'yyyy-mm-dd');
        }

        return data;
      }
    }, {
      targets: 4,
      width: '1%'
    }, {
      targets: 5,
      orderable: false,
      width: '1%'
    }
    ]
  },

  init: function () {
    this.$el = $(this.el)
    this.dataTable = moj.Modules.DataTables._init(this.options, this.el)
    this.bindEvents()
  },

  bindEvents: function () {
    const self = this
    self.$el.on('preDraw.dt', function () {
      self.setOrder()
    })
  },

  setOrder: function () {
    const order = this.dataTable.order()
    const columnIndex = order[0][0]
    const direction = order[0][1]
    // this check is to ensure only type of expense (index 0)
    // and reason for travel (index 1) have secondary order column
    // set to date of expense (index 3) as the current configuration
    // for columnDefs does not support setting sorting direction
    if (columnIndex === 0 || columnIndex === 1) {
      this.dataTable.order([columnIndex, direction], [3, 'asc'])
    }
    if (columnIndex === 3) {
      this.dataTable.order([columnIndex, direction], [0, 'asc'], [1, 'asc'])
    }
  }
}

function parseDate(dateString, _format) {
  // Split the date string into day, month, and year parts
  var parts = dateString.split('/');

  // Extract the numeric values for day, month, and year
  var day = parseInt(parts[0], 10);
  var month = parseInt(parts[1], 10);
  var year = parseInt(parts[2], 10);

  // Create a new JavaScript Date object using the extracted values
  // Note: Months in JavaScript Date objects are zero-based, so we subtract 1 from the month value
  return new Date(year, month - 1, day);
}

function formatDate(date, format) {
  // Extract the year, month, and day from the Date object
  var year = date.getFullYear();
  var month = (date.getMonth() + 1).toString().padStart(2, '0');
  var day = date.getDate().toString().padStart(2, '0');

  // Replace the format placeholders with the actual date values
  format = format.replace('yyyy', year);
  format = format.replace('mm', month);
  format = format.replace('dd', day);

  // Return the formatted date string
  return format;
}
