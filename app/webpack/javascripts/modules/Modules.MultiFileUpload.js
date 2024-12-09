moj.Modules.MultiFileUpload = {
  init: function () {
    new MOJFrontend.MultiFileUpload({
      container: document.querySelector('.moj-multi-file-upload'),
      uploadUrl: '/documents/upload',
      deleteUrl: '/documents/delete'
    });
  }
}
