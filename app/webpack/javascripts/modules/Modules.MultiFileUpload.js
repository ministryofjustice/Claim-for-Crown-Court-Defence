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
        console.log('Success fields')
        console.log(fields)
        const input = document.createElement('input')
        input.type = 'hidden'
        input.name = 'message[document_ids][]'
        input.value = response.file.filename
        fields.appendChild(input)
      },
      uploadFileErrorHook: function (_uploader, file, _jqXHR, _textStatus, errorThrown) {
        console.log('Error fields')
        console.log(fields)
        const input = document.createElement('input')
        input.type = 'hidden'
        input.name = 'message[document_ids][]'
        input.value = errorThrown
        fields.appendChild(input)

        const errorContainer = document.querySelector('.govuk-error-summary')
        const errors = errorContainer.querySelector('.govuk-list.govuk-error-summary__list')
        errorContainer.style.display = ''
        const error = document.createElement('span')
        error.style = 'color:#d4351c;font-weight:bold'
        error.innerHTML = file.name + ' is ' + errorThrown + '.<br/>'
        errors.appendChild(error)
      },
      fileDeleteHook: function (_uploader, response) {
        const input = fields.querySelector('input[value="' + response.file.filename + '"]')
        console.log('remove input')
        console.log(input)
        input.parentNode.removeChild(input)
      }
    })
  }
}
