/* global FormData, XMLHttpRequest */
import { MultiFileUpload } from '@ministryofjustice/frontend'

moj.Modules.MultiFileUpload = {
  init: function () {
    const container = document.querySelector('.moj-multi-file-upload')
    if (!container) return
    const fields = container.querySelector('.moj-multi-file__uploaded-fields')

    const uploadFile = function (file) {
      this.params.uploadFileEntryHook(this, file)
      const formData = new FormData()
      formData.append('document[document]', file)

      this.params.uploadFileParamsHook(this, formData)

      const item = $(this.getFileRowHtml(file))
      this.feedbackContainer.find('.moj-multi-file-upload__list').append(item)

      $.ajax({
        url: this.params.uploadUrl,
        type: 'post',
        data: formData,
        processData: false,
        contentType: false,
        success: $.proxy(function (response) {
          if (response.error) {
            item.find('.moj-multi-file-upload__message').html(this.getErrorHtml(response.error))
            this.status.html(response.error.message)
          } else {
            item.find('.moj-multi-file-upload__message').html(this.getSuccessHtml(response.success))
            this.status.html(response.success.messageText)
          }
          item.find('.moj-multi-file-upload__actions').append(this.getDeleteButtonHtml(response.file))
          this.params.uploadFileExitHook(this, file, response)
        }, this),
        error: $.proxy(function (jqXHR, textStatus, errorThrown) {
          this.params.uploadFileErrorHook(this, file, jqXHR, textStatus, errorThrown)
        }, this),
        xhr: function () {
          const xhr = new XMLHttpRequest()
          xhr.upload.addEventListener('progress', function (e) {
            if (e.lengthComputable) {
              let percentComplete = e.loaded / e.total
              percentComplete = parseInt(percentComplete * 100, 10)
              item.find('.moj-multi-file-upload__progress').text(' ' + percentComplete + '%')
            }
          }, false)
          return xhr
        }
      })
    }

    const uploader = new MultiFileUpload({
      container,
      uploadUrl: '/documents/upload',
      deleteUrl: '/documents/delete',
      uploadFileParamsHook: function (_uploader, formData) {
        const formIdElement = document.querySelector('#claim_form_id')
        if (formIdElement) { formData.append('document[form_id]', formIdElement.value) }
      },
      uploadFileExitHook: function (_uploader, _file, response) {
        const input = document.createElement('input')
        input.type = 'hidden'
        input.name = 'message[document_ids][]'
        input.value = response.file.filename
        fields.appendChild(input)
      },
      uploadFileErrorHook: function (_uploader, file, jqXHR, _textStatus, errorThrown) {
        const input = document.createElement('input')
        input.type = 'hidden'
        input.name = 'message[document_ids][]'
        input.value = errorThrown
        fields.appendChild(input)

        const httpStatus = {
          408: 'Request timeout',
          413: 'File is too large',
          500: 'Internal Server Error',
          502: 'Bad Gateway',
          503: 'Service Unavailable',
          504: 'Gateway Timeout',
          505: 'HTTP Version Not Supported'
        }

        const errorContainer = document.querySelector('.govuk-error-summary')
        const errors = errorContainer.querySelector('.govuk-list.govuk-error-summary__list')
        errorContainer.classList.remove('govuk-visually-hidden')
        const error = document.createElement('span')
        error.style = 'color:#d4351c;font-weight:bold'
        error.innerHTML = file.name + ': ' + httpStatus[jqXHR.status] + '.<br/>'
        errors.appendChild(error)
      },
      fileDeleteHook: function (_uploader, response) {
        const input = fields.querySelector('input[value="' + response.file.filename + '"]')
        input.parentNode.removeChild(input)
      }
    })

    uploader.uploadFile = uploadFile

    return uploader
  }
}
