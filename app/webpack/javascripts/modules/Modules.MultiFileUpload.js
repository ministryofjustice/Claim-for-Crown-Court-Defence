moj.Modules.MultiFileUpload = {
  init: function () {
    let container = document.querySelector('.moj-multi-file-upload');

    new MOJFrontend.MultiFileUpload({
      container: container,
      uploadUrl: '/documents/upload',
      deleteUrl: '/documents/delete',
      uploadFileExitHook: function (uploader, file, response) {
        let fields = container.querySelector('.moj-multi-file__uploaded-fields');
        console.log('fields');
        console.log(fields);
        let input = document.createElement('input');
        input.type = 'hidden';
        input.name = 'message[document_ids][]';
        input.value = response.file.filename;
        fields.appendChild(input);
      },
      fileDeleteHook: function (uploader, response) {
        let fields = container.querySelector('.moj-multi-file__uploaded-fields');
        let input = fields.querySelector('input[value="' + response.file.filename + '"]');
        console.log('remove input');
        console.log(input);
        input.parentNode.removeChild(input);
      }
    });
  }
}
