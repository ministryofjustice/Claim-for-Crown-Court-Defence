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
    this.$forms.on('click', function(e) {
      var $target = $(e.target);
      if ($target.attr('type') === 'button') {
        $target.siblings(':file').click();
      }
    });

    this.$fileInputs.change(function(e) {
      var $form = $(e.target).closest('form');
      var fileName = this.value.replace('C:\\fakepath\\', '');
      $form.removeClass('no-file-selected');
      $form.find('.file-upload-name').text(fileName);
    });
  },

  cacheEls: function() {
    this.$fileInputs = $(this.el);
    this.$forms = this.$fileInputs.closest('form');
    this.$chooseFileNameTmpl = $('<div class="file-upload-name">');
    this.$chooseFileButtonTmpl = $('<button class="button button-secondary" type="button">Choose file</button>');
  }
};
