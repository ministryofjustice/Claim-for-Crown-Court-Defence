moj.Modules.AllocationFilterSubmit = {
  init: function () {
    const reAllocationForm = document.querySelector('.allocation-filter-form')

    if (reAllocationForm) {
      this.autoAllocationFilterSubmit()
      this.setSelectedScheme()
    }
  },

  autoAllocationFilterSubmit: function () {
    const schemeFilters = document.querySelectorAll('.govuk-radios__input[name="scheme"]')

    schemeFilters.forEach(function (scheme) {
      scheme.onchange = function () {
        this.closest('form').submit()
      }
    })
  },

  // circumvent GOVUK radio rule "Do not pre-select radio options"
  // this feature requires a selected state
  setSelectedScheme: function () {
    const selectedScheme = this.getUrlParam('scheme') ? this.getUrlParam('scheme') : 'agfs'
    const selectedSchemeInput = document.querySelector('#scheme-' + selectedScheme + '-field')

    selectedSchemeInput.setAttribute('checked', true)
  },

  // change to Web API: URLSearchParams (https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams)
  // once IE usage fall below 2%
  getUrlParam: function (parameterName) {
    let result = null
    let arr = []
    const queryString = window.location.search.slice(1)

    if (queryString) {
      const parameters = queryString.split('&')

      parameters.forEach(function (parameter) {
        arr = parameter.split('=')
        if (arr[0] === parameterName) {
          result = decodeURIComponent(arr[1])
        }
      })

      return result
    }
  }
}
