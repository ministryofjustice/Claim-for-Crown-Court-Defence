moj.Modules.testing = {
    init: function () {
        new MOJFrontend.MultiFileUpload({
            container: document.querySelector('.moj-multi-file-upload'),
            uploadUrl: '/ajax-upload-url',
            deleteUrl: '/ajax-delete-url'
          });
    }
}