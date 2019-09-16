moj.Modules.ManagementInformation = {
  el: '.fx-dates-chooser',
  download: '#provisional_assessments_date_download',
  disableDownload: true,

  init: function () {
    if ($(this.el).length) {
      this.$el = $(this.el);
      this.$download = $(this.download);
      this.$download.attr('aria-disabled', true);
      this.bindEvents();
    }
  },

  bindEvents: function () {
    this.dateInputEvent();
    this.blockDisabledLinkClick();
  },

  extractDates: function (el) {
    var start = [];
    var end = [];

    this.$el.find('.fx-start-date input').each(function (a, b) {
      start.push($(b).val());
    });

    this.$el.find('.fx-end-date input').each(function (a, b) {
      end.push($(b).val());
    });
    return {
      startDate: start.reverse().join('-'),
      endDate: end.reverse().join('-')
    };
  },

  buildDataArray: function () {
    var dates = this.extractDates();
    return {
      api_key: $('#user_api_key').val(),
      start_date: dates.startDate,
      end_date: dates.endDate,
      format: 'csv'
    };
  },

  buildAttributes: function () {
    var array = [];
    var data = this.buildDataArray();
    $.each(data, function (key, value) {
      array.push(key + "=" + value);
    });
    return array.join('&');
  },

  disableDownloadButton: function () {
    if (!this.$download.hasClass('disabled')) {
      this.$download
        .addClass('disabled')
        .attr('aria-disabled', true);
    }
    this.$download
      .removeAttr("href")
      .attr('aria-disabled', false);
  },

  enableDownloadButton: function () {
    var url = '/api/mi/provisional_assessments?' + this.buildAttributes();
    this.$download.attr("href", url);
    this.$download.removeClass('disabled');
  },

  activateDownload: function () {
    var regex = /^\d{4}\-(0?[1-9]|1[012])\-(0?[1-9]|[12][0-9]|3[01])$/g;
    var data = this.extractDates();

    if (data.startDate.match(regex) && data.endDate.match(regex)) {
      this.enableDownloadButton();
      return true;
    }

    this.disableDownloadButton();
    return false;
  },

  dateInputEvent: function () {
    var self = this;
    this.$el.find('input').on('keyup', function (e) {
      self.activateDownload();
    });
  },

  // blocking the download link
  blockDisabledLinkClick: function () {
    var self = this;
    this.$download.on('click', function (e) {
      if (self.$download.hasClass('disabled')) {
        e.preventDefault();
        return false;
      }
    });
  }
};
