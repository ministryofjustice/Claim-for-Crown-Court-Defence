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
    // date of expense (index 3) desc
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
      render: renderDate
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
      this.dataTable.order([columnIndex, direction], [3, 'desc'])
    } else if (columnIndex === 3) {
      // Sort the date column as a date object
      this.dataTable.order([columnIndex, direction])
    }
  }
}

// Define the named render function
function renderDate (data, type, row) {
  if (type === 'sort') {
    // Check for invalid dates before conversion
    if (!data || isNaN(parseDate(data, 'dd/mm/yyyy'))) {
      return ''
    }

    // Convert the valid date string to a sortable format
    return parseDate(data, 'dd/mm/yyyy')
  }

  return data
}

function parseDate (dateString, _format) {
  // Split the date string into day, month, and year parts
  const parts = dateString.split('/')

  // Extract the numeric values for day, month, and year
  const day = parseInt(parts[0], 10)
  const month = parseInt(parts[1], 10)
  const year = parseInt(parts[2], 10)

  // Create a new JavaScript Date object using the extracted values
  // Note: Months in JavaScript Date objects are zero-based, so we subtract 1 from the month value
  return new Date(year, month - 1, day)
}
