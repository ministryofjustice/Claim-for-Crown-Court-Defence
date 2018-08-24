moj.Modules.ManagementInformation = {
  init: function () {
    this.bindEvents();
  },

  bindEvents: function () {
    this.provisionalAssessmentsDateFieldChange();
    this.provisionalAssessmentsDownloadClicked();
  },

  buildDataArray: function() {
    var data = {};
    data.api_key='64c9177b-e5a0-4ac5-9f2b-33166597c436';
    data.start_date=$('#start_date').val();
    data.end_date=$('#end_date').val();
    data.format='csv';
    return data;
  },

  buildAttributes: function() {
    var array=[];
    var data=this.buildDataArray();
    $.each(data, function(key, value) { array.push(key+"="+value) });
    return array.join('&');
  },

  disableDownloadButton: function() {
    var downloadButton = $('#provisional_assessments_date_download');
    if(!downloadButton.hasClass('disabled')) { downloadButton.addClass('disabled'); }
    downloadButton.removeAttr("href");
  },

  enableDownloadButton: function() {
    var downloadButton = $('#provisional_assessments_date_download');
    var url = '/api/mi/provisional_assessments?'+ this.buildAttributes();
    downloadButton.attr("href", url );
    downloadButton.removeClass('disabled');
  },

  provisionalAssessmentsDateFieldChange: function () {
    var self=this;
    $('.provisional_assessments_date_field').change( function() {
      var disableDownload=false;
      $('.provisional_assessments_date_field').each( function() {
        if (this.value == '') { disableDownload = true; }
      });
      if(disableDownload) {
        self.disableDownloadButton();
      } else {
        self.enableDownloadButton();
      }
    });
  },

  provisionalAssessmentsDownloadClicked: function () {
    $('#provisional_assessments_date_download').on('click', function(e) {
      if ($('#provisional_assessments_date_download').hasClass('disabled')) {
        e.preventDefault();
        return false;
      }
    });
  }
};
