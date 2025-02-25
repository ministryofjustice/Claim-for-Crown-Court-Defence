/* global MOJFrontend */

moj.Modules.MultiFileUpload = {
  init: function () {
    const container = document.querySelector('.moj-multi-file-upload')
    if (!container) return
    const fields = container.querySelector('.moj-multi-file__uploaded-fields')

    return new MOJFrontend.MultiFileUpload({
      container,
      uploadUrl: '/documents/upload',
      deleteUrl: '/documents/delete',
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
  }
}
