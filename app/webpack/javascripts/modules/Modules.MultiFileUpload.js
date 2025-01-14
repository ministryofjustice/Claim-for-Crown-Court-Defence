moj.Modules.MultiFileUpload = {
  init: function () {
    let container = document.querySelector('.moj-multi-file-upload');
    let fields = container.querySelector('.moj-multi-file__uploaded-fields');

    new MOJFrontend.MultiFileUpload({
      container: container,
      uploadUrl: '/documents/upload',
      deleteUrl: '/documents/delete',
      uploadFileExitHook: function (uploader, file, response) {
        console.log('Success fields');
        console.log(fields);
        let input = document.createElement('input');
        input.type = 'hidden';
        input.name = 'message[document_ids][]';
        input.value = response.file.filename;
        fields.appendChild(input);
      },
      uploadFileErrorHook: function (uploader, file, jqXHR, textStatus, errorThrown) {
        console.log('Error fields');
        console.log(fields);
        let input = document.createElement('input');
        input.type = 'hidden';
        input.name = 'message[document_ids][]';
        input.value =  errorThrown;
        fields.appendChild(input);
        
        let errorContainer = document.querySelector('.govuk-error-summary');
        let errors = errorContainer.querySelector('.govuk-list.govuk-error-summary__list');
        errorContainer.style.display = '';
        let error = document.createElement('span');
        error.style = 'color:#d4351c;font-weight:bold';
        error.innerHTML = file.name + ' is ' + errorThrown + '.<br/>';
        errors.appendChild(error);
      },
      fileDeleteHook: function (uploader, response) {
        let input = fields.querySelector('input[value="' + response.file.filename + '"]');
        console.log('remove input');
        console.log(input);
        input.parentNode.removeChild(input);
      }
    });
  }
}
