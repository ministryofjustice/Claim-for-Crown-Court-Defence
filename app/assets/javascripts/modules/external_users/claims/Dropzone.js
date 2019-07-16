moj.Modules.Dropzone = {
  init: function () {
    var self = this;

    this.$target = $('.dropzone');

    Dropzone.autoDiscover = false;

    if (self.dragAndDropSupported() && self.formDataSupported() && self.fileApiSupported()) {
      this.$target.addClass('dropzone-enhanced');
      self.setupDropzone();
      self.setupFileInput();
      self.setupStatusBox();
      $('.files').on('click', '.file-remove', $.proxy(this, 'onFileRemoveClick'));
    }

  },

  dragAndDropSupported: function () {
    var div = document.createElement('div');
    return typeof div.ondrop != 'undefined';
  },

  formDataSupported: function () {
    return typeof FormData == 'function';
  },

  fileApiSupported: function () {
    var input = document.createElement('input');
    input.type = 'file';
    return typeof input.files != 'undefined';
  },

  setupDropzone: function () {
    this.$target.on('dragover', $.proxy(this, 'onDragOver'));
    this.$target.on('dragleave', $.proxy(this, 'onDragLeave'));
    this.$target.on('drop', $.proxy(this, 'onDrop'));
  },

  setupFileInput: function () {
    this.$fileInput = this.$target.find('[type=file]');
    this.$fileInput.on('change', $.proxy(this, 'onFileChange'));
    this.$fileInput.on('focus', $.proxy(this, 'onFileFocus'));
    this.$fileInput.on('blur', $.proxy(this, 'onFileBlur'));
  },

  setupStatusBox: function () {
    this.$status = $('<div aria-live="polite" role="status" class="visually-hidden" />');
    this.$target.append(this.status);
  },

  toggleFileStatus: function () {
    $('.files tbody tr').length >= 1 ? $('.files').removeClass('hidden') : $('.files').addClass('hidden')
  },

  onFileChange: function (e) {
    this.$status.html('Uploading files, please wait.');
    this.uploadFiles(e.currentTarget.files);
  },

  onFileRemoveClick: function (e) {
    var documentId = e.currentTarget.getAttribute('data-id');
    this.$status.html('Processing file, please wait.');
    if (documentId) {
      $('#claim_document_ids_' + documentId).remove();
    } else {
      $(e.target).parent().parent().remove();
    }
    this.toggleFileStatus();
  },

  onDragOver: function (e) {
    e.preventDefault();
    this.$target.addClass('dropzone-dragover');
  },

  onDragLeave: function () {
    this.$target.removeClass('dropzone-dragover');
  },

  onDrop: function (e) {
    e.preventDefault();
    this.$target.removeClass('dropzone-dragover');
    this.$status.html('Uploading files, please wait.');
    this.uploadFiles(e.originalEvent.dataTransfer.files);
  },

  onFileFocus: function (e) {
    this.$target.find('label').addClass('dropzone-focused');
  },

  onFileBlur: function (e) {
    this.$target.find('label').removeClass('dropzone-focused');
  },

  getSuccessHtml: function (file) {
    var html = '<tr id="document_' + file.id + '"><td>' + file.document_file_name + '</td>';
    html += '<td><span class="success">File uploaded</span></td>';
    html += '<td><a aria-label="Remove document: ' + file.document_file_name + '" class="file-remove" data-id="' + file.id + '" data-remote="true" data-method="delete" href="/documents/' + file.id + '" rel="nofollow">Remove</a></td></tr>';
    return html;
  },

  getErrorHtml: function (error, file) {
    var html = '<tr><td><span class="file-name">' + file + '</span></td>'
    html += '<td><span class="error">' + error.error + '</span></td>'
    html += '<td><a aria-label="Remove document: ' + file.document_file_name + '" class="file-remove" href="#" rel="nofollow">Remove</a></td></tr>';
    return html;
  },

  createDocumentIdInput: function (id) {
    var input = '<input multiple="multiple" value="' + id + '" id="claim_document_ids_' + id + '" type="hidden" name="claim[document_ids][]"></input>';
    $('.document-ids').append(input);
  },

  uploadFiles: function (files) {
    for (var i = 0; i < files.length; i++) {
      this.uploadFile(files[i]);
      this.toggleFileStatus();
    }
  },

  uploadFile: function (file) {
    var formData = new FormData();
    formData.append('document[document]', file);
    var tableBody = $('.files tbody');
    var tableRow = $('<tr><td><span class="file-name">' + formData.get('document[document]').name + '</span></td><td colspan="2"><progress value="0" max="100">0%</progress></td></tr>');
    tableBody.append(tableRow);

    var form_id = $('#claim_form_id').val();
    formData.append('document[form_id]', form_id);

    $.ajax({
      url: '/documents',
      type: 'post',
      data: formData,
      processData: false,
      contentType: false,

      success: $.proxy(function (response) {
        this.createDocumentIdInput(response.document.id);
        tableRow.replaceWith(this.getSuccessHtml(response.document));
        this.$status.html(response.document.document_file_name + ' has been uploaded.');
      }, this),

      error: $.proxy(function (xhr, status, error) {
        var errMsg = xhr.responseJSON.error;
        var document_name = formData.get('document[document]').name;

        tableRow.replaceWith(this.getErrorHtml(xhr.responseJSON, document_name));
        this.$status.html(document_name + ' ' + errMsg);
      }, this),

      xhr: function () {
        var xhr = new XMLHttpRequest();
        xhr.upload.addEventListener('progress', function (e) {
          if (e.lengthComputable) {
            var percentComplete = e.loaded / e.total;
            percentComplete = parseInt(percentComplete * 100);
            tableRow.find('progress').prop('value', percentComplete).text(percentComplete + '%');
          }
        }, false);
        return xhr;
      }
    });
  }

};


moj.Modules.ExternalLinks = {
  init: function () {
    $('[rel="external"]').is(function (id, el) {
      $(el).append('<span class="visuallyhidden">opens in new window</span>');
    });
  }
};
