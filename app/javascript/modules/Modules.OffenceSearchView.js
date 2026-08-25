/**
 * OffenceSearchView View controller
 */
moj.Modules.OffenceSearchView = {
  // view selector
  view: '.fx-view',

  // filters view selector
  filtersView: '.fx-filters-display',

  // page controls selector
  pageControls: '.button-holder',

  /**
   * init called my moj.init()
   */
  init: function () {
    const self = this

    // cache jQuery referances for each view
    this.$view = $(this.view)
    this.$filtersView = $(this.filtersView)
    this.$pageControls = $(this.pageControls)

    // Event: search results available to render
    $.subscribe('/offence/search/results/', function (e, data) {
      self.render(data)
      self.$view.show()
      self.$pageControls.toggle(false)
    })

    // Event: page control state changes
    $.subscribe('/office/search/pageControls/', function (e, state) {
      self.$pageControls.toggle(state)
    })

    // Event: clear search + results
    $.subscribe('/offence/search/clear/', function () {
      self.$view.hide()
      self.$view.find('.fx-results').empty()
      self.$view.find('.fx-filters-display p').empty()
      self.$view.find('.fx-results-found p').empty()

      if (!moj.Modules.OffenceSelectedView.isVisible()) {
        self.$pageControls.toggle(true)
      }
    })

    // Event: create rails model / submit the form
    $(document.body).on('click', '.set-selection', function (e) {
      const $element = $(e.target)
      const data = $element.data()
      const field = $(data.field)
      const value = data.value
      if (field) {
        field.attr('value', value)
        const form = field.closest('form')
        // NOTE: simulate a normal form submit
        $('<input />')
          .attr('type', 'hidden')
          .attr('name', 'commit_continue')
          .attr('value', 'Submit')
          .appendTo(form)
        form.submit()
      }
    })

    // Event: Apply filter(s)
    $('.fx-view').on('click', '.fx-filter', function (e) {
      e.preventDefault()
      const $el = $(this)
      const filter = {}
      $.each($el.data(), function (key, val) {
        filter[key + '_id'] = val
      })

      $.publish('/offence/search/filter/', filter)
    })

    // Event: Remove filters
    $('.fx-view').on('click', '.fx-clear-filters', function (e) {
      e.preventDefault()
      $.publish('/offence/search/filter/', {})
    })
  },

  /**
   * filterResults template
   * @param  {object} options Data to render to the view
   * @return {string}         View content
   */
  filterResults: function (options) {
    let str = ''

    str += 'Showing offences'

    if (options.band_id) {
      str += ' in <span class="bold-small">Band: ' + options.results[0].band.description + '</span>'
    }

    if (options.category_id) {
      str += ' in the <span class="bold-small">' + options.results[0].category.description + '</span> class. <a href="#noop" class="fx-clear-filters">Clear filters</a>.'
    }

    return str === 'Showing offences' ? '' : str
  },

  /**
   * render Render the view and attach to DOM
   * @param  {object} options results data
   */
  render: function (options) {
    const results = this.$view.find('.fx-results')
    results.empty()
    const card = document.getElementById('fx-results-template')
    options.results.forEach((data) => {
      const result = card.content.cloneNode(true).querySelector('div')

      const category = result.getElementsByClassName('category')[0]
      category.innerHTML = data.category.description
      category.setAttribute('data-category', data.category.id)

      const band = result.getElementsByClassName('band')[0]
      band.innerHTML = `Band: ${data.band.description}`
      band.setAttribute('data-category', data.category.id)
      band.setAttribute('data-band', data.band.id)

      result.getElementsByClassName('description')[0].innerHTML = data.description
      result.getElementsByClassName('contrary')[0].innerHTML = data.contrary
      result.getElementsByClassName('button')[0].setAttribute('data-value', data.id)

      results.append(result)
    })

    this.$view.find('.fx-filters-display p').empty()
    this.$view.find('.fx-filters-display p').append(this.filterResults(options))

    this.$view.find('.fx-results-found p').empty()
    this.$view.find('.fx-results-found p').append('Results found: ' + options.results.length + ' <a href="#noop" class="fx-clear-search hidden">Clear search</a>')

    this.$view.find('.fx-results').highlight(options.search_offence)
  }
}
