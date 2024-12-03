moj.Modules.MultiFileUpload = {
    init: function () {
        new MOJFrontend.MultiFileUpload({
            container: document.querySelector('.moj-multi-file-upload'),
            uploadUrl: '/message_documents',
            deleteUrl: '/message_documents'
          });
    }
}