/**
 * OffenceSearchInput
 * A controller to handel search input,
 * state and provide results data
 */

moj.Modules.OffenceSearchInput = {
  // component selector
  el: '.mod-search-input',

  // search input selector
  input: '.fx-input',

  // hidden input to store model value
  model: '.fx-model',

  // clear button selector
  clear: '.fx-clear-search',

  // fee_scheme selector
  feeScheme: '.fx-fee-scheme',

  // delay in miliseconds
  debounce: 500,

  // min input length to trigger search
  minLength: 3,

  // publisher names
  publishers: {
    // API results recieved
    results: '/offence/search/results/'
  },

  // subscriber names
  subscribers: {
    // trigger the API call
    run: '/offence/search/run/',

    // apply filters to the API call
    filter: '/offence/search/filter/'
  },

  init: function () {
    this.$el = $(this.el)
    if (this.$el.length > 0) {
      this.$input = $(this.input)
      this.$model = $(this.model)
      this.$clear = $(this.clear)
      this.$feeScheme = $(this.feeScheme)
      this.bindEvents()
    }
  },

  bindEvents: function () {
    this.clearSearch()
    this.bindSubscribers()
    this.trackUserInput()
  },

  // binding subscribers and callbacks
  bindSubscribers: function () {
    const self = this

    $.subscribe(this.subscribers.run, function () {
      self.runQuery()
    })

    $.subscribe(this.subscribers.filter, function (e, options) {
      self.runQuery(options)
    })
  },

  runQuery: function (options) {
    const self = this

    // dataOptions for the api request
    // defaults, search input and filters
    const dataOptions = {
      // default value
      fee_scheme: this.$feeScheme.val(),

      // Search query text
      search_offence: this.$input.val(),

      // filters are applied
      ...options
    }

    this.query(dataOptions).then(function (data) {
      // showing the clear search button
      self.$clear.removeClass('hidden')

      // publish the response data
      $.publish(self.publishers.results, data)
    })
  },

  query: function (options) {
    const _options = options
    const def = $.Deferred()
    $.ajax({
      type: 'GET',
      url: '/offences',
      data: _options,
      dataType: 'json',
      success: function (results) {
        options.results = results || []
        def.resolve(_options)
      },
      error: function (req, status, err) {
        def.reject(status, err)
      }
    })

    return def.promise()
  },

  // Tracking the user inout and calling the API
  // when required. Uses $.debounce to limit calls

  trackUserInput: function () {
    const self = this
    this.$input.on('keyup', moj.Modules.Debounce.init(function (e) {
      if (self.$input.val().length >= 3) {
        self.runQuery()
      }
    }, 290))
  },

  // clearSearch procedure
  clearSearch: function () {
    const self = this
    self.$clear.on('click', function (e) {
      e.preventDefault()
      self.$clear.addClass('hidden')
      self.$el.find('.fx-input').val('')
      self.$el.find('.fx-model').val('')
      $.publish('/offence/search/clear/')
    })
  }
}
