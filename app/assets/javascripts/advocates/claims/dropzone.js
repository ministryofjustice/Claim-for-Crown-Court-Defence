"use strict";

var adp = adp || {};

adp.dropzone = {

  $target: {},
  init : function() {
    adp.dropzone.$target = $('.dropzone');
    adp.dropzone.$document_ids = $('.document-ids');

    Dropzone.autoDiscover = false;

    adp.dropzone.$target.dropzone({
      url: "/documents",
      addRemoveLinks: true,
      maxFilesize: 20,
      paramName: "document[document]",
      createImageThumbnails: false,
      headers: { "X-CSRF-Token" : $('meta[name="csrf-token"]').attr('content') },
      init: function() {
        var thisDropzone = this;

        $.getJSON('/documents/?form_id=' + $('#form_id').val()).done(function (data) {
          if(data) {
            $.each(data, function(index, item) {
              var existingFile = {
                name: item.document_file_name,
                size: parseInt(item.document_file_size),
                accepted: true
              };
              thisDropzone.emit('addedfile', existingFile);
              thisDropzone.emit('success', existingFile, { document : item });
              thisDropzone.emit('complete', existingFile);
            });
          }
        });
      },
      sending: function(file, xhr, formData) {
        var form_id = $('#form_id').val();
        formData.append("document[form_id]", form_id);
      },
      success: function (file, response) {
        var id = response['document']['id'];
        $(file.previewTemplate).find('.dz-remove').attr('id', id);
        file.previewElement.classList.add('dz-success');

        if(file.accepted) {
          $(file.previewElement).find('.dz-upload').css('width', '100%');
        }

        adp.dropzone.createDocumentIdInput(id);
      },
      removedfile: function(file) {
        var id = $(file.previewTemplate).find('.dz-remove').attr('id');

        if(id) {
          $.ajax({
            type: 'DELETE',
            url: '/documents/' + id,
            success : function(data) {
              // console.log(data.message + ' ' + data.document.id);
              file.previewElement.remove();
              adp.dropzone.removeDocumentIdInput(data.document.id);
            }
          });
        }
        else {
          file.previewElement.remove();
        }
      }
    });
  },
  createDocumentIdInput : function(id) {
    var input = "<input id=\"claim_document_ids_" + id + "\" multiple=\"multiple\" name=\"claim[document_ids][]\" type=\"hidden\" value=\"" + id + "\">"
    adp.dropzone.$document_ids.append(input);
  },
  removeDocumentIdInput : function(id) {
    $('#claim_document_ids_' + id).remove();
  }
};
