moj.Modules.Messaging = {
  init: function () {
    const self = this

    self.cacheEls()

    if (self.messagesList.length) {
      self.messagesList.scrollTop(self.messagesList.prop('scrollHeight'))
    }

    self.selectedFileUpload()
    self.removeSelectedFile()

    self.messageControls.on('change', ':radio', function () {
      const data = $('.js-test-claim-action :radio:checked').val()
      $.getScript(self.messageControls.data('auth-url') + '?claim_action=' + data)
    })
  },
  /******************************
   rorData = Data object received from Ruby on Rails
   ******************************/
  processMsg: function (rorData) {
    // Cache the flag that says whether msg was sent
    const status = rorData.success
    const adpMsg = this

    if (status === true) { // if successful
      $('.message-column').removeClass('govuk-form-group--error')
      $('.govuk-textarea').removeClass('govuk-textarea--error')

      $('.message-status p')
        .removeClass()
        .addClass('message-success')
        .text(rorData.statusMessage)

      adpMsg.clearUserMessageBody()
      $('.no-messages').hide()
      $('.file-to-be-uploaded').hide()
      $('#message-attachment-field').val('')
      this.messagesList.html(rorData.sentMessage).scrollTop(this.messagesList.prop('scrollHeight'))

      // Clear multi-file upload details
      const fileList = document.querySelector('.govuk-summary-list.moj-multi-file-upload__list')
      if (fileList) { fileList.innerHTML = '' }
      const fileFields = document.querySelector('.moj-multi-file__uploaded-fields')
      if (fileFields) { fileFields.innerHTML = '' }
      const errorContainer = document.querySelector('.govuk-error-summary')
      if (errorContainer) {
        errorContainer.classList.add('govuk-visually-hidden')
        errorContainer.querySelector('.govuk-list.govuk-error-summary__list').innerHTML = ''
      }
    } else { // If there was an error
      $('.message-column').addClass('govuk-form-group--error')
      $('.govuk-textarea').addClass('govuk-textarea--error')

      $('.message-status p')
        .removeClass()
        .addClass('message-error')
        .text(rorData.statusMessage)
    }
  },

  /**********************************
   Clear the User message so they can
   input another message
   **********************************/
  clearUserMessageBody: function () {
    $('#message-body-field').val('')
  },

  /********************************
   Upload button functionality
   ********************************/
  selectedFileUpload: function () {
    const self = this

    self.messageControls.on('change', '#message-attachment-field', function () {
      const $element = $(this)
      const filename = $element.val().replace(/C:\\fakepath\\/i, '')
      const $controls = self.messageControls

      $controls.find('.filename').text(filename)
      $('.file-to-be-uploaded').show()
      filename ? $('.file-to-be-uploaded').show() : $('.file-to-be-uploaded').hide()
    })
  },
  /********************************
   Remove selected file to be uploaded
   ********************************/
  removeSelectedFile: function () {
    this.messageControls.on('click', '.file-to-be-uploaded a', function (event) {
      const $element = $(this)

      event.preventDefault()
      $element.closest('.file-to-be-uploaded').hide()
      $('#message-attachment-field').val('')
    })
  },

  cacheEls: function () {
    this.messagesList = $('.messages-list')
    this.messageControls = $('.message-controls')
  }
}
