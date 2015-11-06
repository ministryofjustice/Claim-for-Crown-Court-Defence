moj.Modules.CustomFileUpload = {
  el: 'input:file.custom-uploader',

  init: function() {
    this.cacheEls();
    this.bindEvents();
    this.setUp();
  },

  setUp: function() {
    this.$forms.addClass('no-file-selected');
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
          .removeClass('no-file-selected')
          .find('.file-upload-name').text(fileName)
          .parent()
          .find('.errors').empty();
      });
  },

  cacheEls: function() {
    this.$fileInputs = $(this.el);
    this.$forms = this.$fileInputs.closest('form');
    this.$chooseFileNameTmpl = $('<div class="file-upload-name">');
    this.$chooseFileButtonTmpl = $('<button class="button button-secondary" type="button">Choose file</button>');
  }
};
