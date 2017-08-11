moj.Modules.CustomFileUpload = {
  el: 'input:file.custom-uploader',
  tpml: {
    button: ['<button class="button button-secondary external-user-json-export" type="button">Choose file</button>'].join(''),
    text: ['<p tabindex="0" class="file-upload-name" aria-hidden="true" ><span class="visuallyhidden">File name:</span></p>'].join('')
  },

  init: function() {
    $('.btn-import-file').hide().attr('aria-hidden', 'true');
    this.cacheEls();
    this.bindEvents();
    this.setUp();
  },

  setUp: function() {
    this.$fileInputs
      .after(this.$chooseFileButtonTmpl.clone())
      .after(this.$chooseFileNameTmpl.clone());
  },

  bindEvents: function() {
    this.$forms
      .on('click', function(e) {
        var $target = $(e.target);
        if ($target.attr('type') === 'button') {
          $target.siblings(':file').click();
        }
      })
      .on('change', ':file', function(e) {
        var fileName = this.value.replace('C:\\fakepath\\', '');
        $(e.target).closest('form')
          .find('.file-upload-name').append(fileName).attr('aria-hidden','')
          .parent()
          .find('.errors').empty();

        $('.file-upload-name').focus();
        $('.btn-import-file').show().attr('aria-hidden', '');

      })
      .on('submit', function() {
        $('input.btn-import-file').prop('disabled', true).val('Please wait...');
      });
  },

  cacheEls: function() {
    this.$fileInputs = $(this.el);
    this.$forms = this.$fileInputs.closest('form');
    this.$chooseFileNameTmpl = $(this.tpml.text);
    this.$chooseFileButtonTmpl = $(this.tpml.button);
  }
};
