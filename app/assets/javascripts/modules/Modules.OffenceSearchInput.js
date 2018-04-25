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

  // delay in miliseconds
  debouce: 500,

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

  init: function() {
    this.$el = $(this.el);
    if (this.$el.length > 0) {
      this.$input = $(this.input);
      this.$model = $(this.model);
      this.$clear = $(this.clear);
      this.bindEvents();
    }
  },

  bindEvents: function() {
    this.clearSearch();
    this.bindSubscribers();
    this.trackUserInput();
  },

  // binding subscribers and callbacks
  bindSubscribers: function() {
    var self = this;

    $.subscribe(this.subscribers.run, function() {
      self.runQuery();
    });

    $.subscribe(this.subscribers.filter, function(e, options) {
      self.runQuery(options);
    });
  },

  runQuery: function(options) {
    var self = this;

    // dataOptions for the api request
    // defaults, search input and filters
    var dataOptions = $.extend({}, {
        // default value
        fee_scheme: 'fee_reform',

        // Search query text
        search_offence: this.$input.val()
      },

      // filters are applied
      options);

    this.query(dataOptions).then(function(data) {
      // showing the clear search button
      self.$clear.show();

      // publish the response data
      $.publish(self.publishers.results, data);
    });
  },

  query: function(options) {
    var _options = options;
    var self = this;
    var def = $.Deferred();
    $.ajax({
      type: 'GET',
      url: '/offences',
      data: _options,
      dataType: 'json',
      success: function(results) {
        options.results = results || [];
        def.resolve(_options);
      },
      error: function(req, status, err) {
        def.reject(status, err)
      }
    });

    return def.promise();
  },

  // Tracking the user inout and calling the API
  // when required. Uses $.debounce to limit calls
  trackUserInput: function() {
    var self = this;
    this.$input.on('keyup', $.debounce(290, function(e) {
      if (self.$input.val().length >= 3) {
        self.runQuery();
      }
    }));
  },

  // clearSearch procedure
  clearSearch: function() {
    var self = this;
    this.$el.on('click', '.fx-clear-search', function(e) {
      e.preventDefault();
      self.$clear.hide();
      self.$el.find('.fx-input').val('');
      self.$el.find('.fx-model').val('');
      $.publish('/offence/search/clear/');
    });
  }
};