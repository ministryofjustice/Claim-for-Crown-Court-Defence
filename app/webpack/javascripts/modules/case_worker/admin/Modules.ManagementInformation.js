moj.Modules.ManagementInformation = {
  el: '.fx-dates-chooser',
  download: '#provisional_assessments_date_download',

  init: function () {
    if ($(this.el).length) {
      this.$el = $(this.el)
      this.$download = $(this.download)
      this.$download.attr('aria-disabled', true)
      this.bindEvents()
    }
  },

  bindEvents: function () {
    this.dateInputEvent()
    this.blockDisabledLinkClick()
  },

  extractDates: function (el) {
    const start = []
    const end = []

    this.$el.find('.fx-start-date input').each(function (a, b) {
      start.push($(b).val())
    })

    this.$el.find('.fx-end-date input').each(function (a, b) {
      end.push($(b).val())
    })
    return {
      startDate: start.reverse().join('-'),
      endDate: end.reverse().join('-')
    }
  },

  buildDataArray: function () {
    const dates = this.extractDates()
    return {
      api_key: $('#user_api_key').val(),
      start_date: dates.startDate,
      end_date: dates.endDate,
      format: 'csv'
    }
  },

  buildAttributes: function () {
    const array = []
    const data = this.buildDataArray()
    $.each(data, function (key, value) {
      array.push(key + '=' + value)
    })
    return array.join('&')
  },

  disableDownloadButton: function () {
    if (!this.$download.hasClass('disabled')) {
      this.$download.addClass('disabled')
    }
    this.$download.removeAttr('href')
    this.$download.attr('disabled', true)
    this.$download.attr('aria-disabled', true)
  },

  enableDownloadButton: function () {
    const url = '/api/mi/provisional_assessments?' + this.buildAttributes()
    this.$download.attr('href', url)
    this.$download.removeClass('disabled')
    this.$download.removeAttr('disabled')
    this.$download.attr('aria-disabled', false)
  },

  activateDownload: function () {
    const regex = /^\d{4}-(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01])$/g
    const data = this.extractDates()

    if (data.startDate.match(regex) && data.endDate.match(regex)) {
      this.enableDownloadButton()
      return true
    }

    this.disableDownloadButton()
    return false
  },

  dateInputEvent: function () {
    const self = this
    this.$el.find('input').on('keyup', function (e) {
      self.activateDownload()
    })
  },

  // blocking the download link
  blockDisabledLinkClick: function () {
    const self = this
    this.$download.on('click', function (e) {
      if (self.$download.hasClass('disabled')) {
        e.preventDefault()
        return false
      }
    })
  }
}
