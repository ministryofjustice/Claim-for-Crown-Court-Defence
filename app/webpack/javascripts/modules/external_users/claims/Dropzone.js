/* global Dropzone, FormData, XMLHttpRequest */

moj.Modules.Dropzone = {
  init: function () {
    const self = this

    this.target = $('.dropzone')

    Dropzone.autoDiscover = false

    if (self.dragAndDropSupported() && self.formDataSupported() && self.fileApiSupported()) {
      this.target.addClass('dropzone-enhanced')
      self.setupDropzone()
      self.setupFileInput()
      self.setupStatusBox()
      $('.files').on('click', '.govuk-link', this.onFileRemoveClick.bind(this))
    }
  },

  dragAndDropSupported: function () {
    const div = document.createElement('div')
    return typeof div.ondrop !== 'undefined'
  },

  formDataSupported: function () {
    return typeof FormData === 'function'
  },

  fileApiSupported: function () {
    const input = document.createElement('input')
    input.type = 'file'
    return typeof input.files !== 'undefined'
  },

  setupDropzone: function () {
    this.target.on('dragover', this.onDragOver.bind(this))
    this.target.on('dragleave', this.onDragLeave.bind(this))
    this.target.on('drop', this.onDrop.bind(this))
  },

  setupFileInput: function () {
    this.fileInput = this.target.find('[type=file]')
    this.fileInput.on('change', this.onFileChange.bind(this))
    this.fileInput.on('focus', this.onFileFocus.bind(this))
    this.fileInput.on('blur', this.onFileBlur.bind(this))
  },

  setupStatusBox: function () {
    this.status = $('<div aria-live="polite" role="status" class="govuk-visually-hidden" />')
    this.target.append(this.status)
  },

  toggleFileStatus: function () {
    setTimeout(function () {
      $('#dropzone-files tbody .govuk-table__row').length >= 1 ? $('#dropzone-files').removeClass('hidden') : $('#dropzone-files').addClass('hidden')
    }, 250)
  },

  onFileChange: function (e) {
    this.status.html('Uploading files, please wait.')
    this.uploadFiles(e.currentTarget.files)
  },

  onFileRemoveClick: function (e) {
    e.preventDefault()
    const fileId = e.currentTarget.getAttribute('data-id')
    this.status.html('Removing file, please wait.')
    if (fileId) {
      $('#claim_document_ids_' + fileId).remove()
    } else {
      $(e.target).parent().parent().remove()
    }
    this.status.html('File removed.')
    this.toggleFileStatus()
  },

  onDragOver: function (e) {
    e.preventDefault()
    this.target.addClass('dropzone-dragover')
  },

  onDragLeave: function () {
    this.target.removeClass('dropzone-dragover')
  },

  onDrop: function (e) {
    e.preventDefault()
    this.target.removeClass('dropzone-dragover')
    this.status.html('Uploading files, please wait.')
    this.uploadFiles(e.originalEvent.dataTransfer.files)
  },

  onFileFocus: function (e) {
    this.target.find('label').addClass('dropzone-focused')
  },

  onFileBlur: function (e) {
    this.target.find('label').removeClass('dropzone-focused')
  },

  notificationHTML: function (fileName, fileStatus, fileStatusMsg, fileId) {
    let html = ''

    if (fileId) {
      html += '<tr id="document_' + fileId + '" class="govuk-table__row"><td data-label="File name" class="govuk-table__cell">' + fileName + '</td>'
    } else {
      html += '<tr class="govuk-table__row"><td data-label="File name" class="govuk-table__cell">' + fileName + '</td>'
    }

    html += '<td data-label="Status" class="govuk-table__cell"><span class="' + fileStatus + '">' + fileStatusMsg + '</span></td>'

    if (fileId) {
      html += '<td data-label="Action" class="govuk-table__cell"><a aria-label="Remove document: ' + fileName + '" class="govuk-link" data-id="' + fileId + '" data-remote="true" data-method="delete" href="/documents/' + fileId + '" rel="nofollow">Remove</a></td></tr>'
    } else {
      html += '<td data-label="Action" class="govuk-table__cell"><a aria-label="Remove document: ' + fileName + '" class="govuk-link" href="#dropzone-files" rel="nofollow">Remove</a></td>'
    }

    html += '</tr>'

    return html
  },

  createDocumentIdInput: function (id) {
    const input = '<input multiple="multiple" value="' + id + '" id="claim_document_ids_' + id + '" type="hidden" name="claim[document_ids][]"></input>'
    $('.document-ids').append(input)
  },

  uploadFiles: function (files) {
    for (let i = 0; i < files.length; i++) {
      if (files[i].size >= 20971520) {
        const tableBody = $('#dropzone-files tbody')
        tableBody.prepend(this.notificationHTML(files[i].name, 'govuk-tag govuk-tag--red', 'File too large'))
      } else {
        this.uploadFile(files[i])
      }
      this.toggleFileStatus()
    }
  },

  uploadFile: function (file) {
    const formData = new FormData()
    formData.append('document[document]', file)

    const tableBody = $('#dropzone-files tbody')
    const tableRow = $('<tr class="govuk-table__row"><td data-label="File name" class="govuk-table__cell"><span class="file-name">' + file.name + '</span></td><td data-label="Upload Progress" class="govuk-table__cell"><progress value="0" max="100">0%</progress></td><td></td></tr>')
    tableBody.prepend(tableRow)

    const formId = $('#claim_form_id').val()
    formData.append('document[form_id]', formId)

    $.ajax({
      url: '/documents',
      type: 'post',
      data: formData,
      maxFilesize: 20,
      processData: false,
      contentType: false,

      success: function (response) {
        const fileName = response.document.filename
        const fileId = response.document.id

        this.createDocumentIdInput(response.document.id)
        tableRow.replaceWith(this.notificationHTML(fileName, 'govuk-tag govuk-tag--green', 'Uploaded', fileId))
        this.status.html(response.document.filename + ' has been uploaded.')
      }.bind(this),

      error: function (xhr, status, error) {
        const fileName = file.name
        const errorMessage = xhr.responseJSON ? xhr.responseJSON.error : xhr.responseText
        const govukError = 'govuk-tag govuk-tag--red word-wrap'

        if (status === 'timeout') {
          tableRow.replaceWith(this.notificationHTML(fileName, govukError, 'Upload timed out'))
          this.status.html('Upload timed out')
        } else if (errorMessage.includes('Unprocessable Content') || errorMessage.includes('invalid content type')) {
          tableRow.replaceWith(this.notificationHTML(fileName, govukError, 'Invalid file type'))
          this.status.html('Invalid file type')
        } else {
          tableRow.replaceWith(this.notificationHTML(fileName, govukError, errorMessage))
          this.status.html(`${fileName} ${errorMessage}`)
        }
      }.bind(this),

      xhr: function () {
        const xhr = new XMLHttpRequest()
        xhr.upload.addEventListener('progress', function (e) {
          if (e.lengthComputable) {
            let percentComplete = e.loaded / e.total
            percentComplete = parseInt(percentComplete * 100)
            tableRow.find('progress').prop('value', percentComplete).text(percentComplete + '%')
          }
        }, false)
        return xhr
      }
    })
  }

}
