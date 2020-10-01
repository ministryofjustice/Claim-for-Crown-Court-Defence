moj.Modules.Messaging = {
  init :function(){
    var self = this;

    self.cacheEls();

    if(self.messagesList.length) {
      self.messagesList.scrollTop(self.messagesList.prop('scrollHeight'));
    }

    self.selectedFileUpload();
    self.removeSelectedFile();

    self.messageControls.on('change', ':radio',function() {
      var data = $('.js-test-claim-action :radio:checked').val();
      $.getScript(self.messageControls.data('auth-url') + '?claim_action=' + data);
    });
  },
  /******************************
   rorData = Data object received from Ruby on Rails
   ******************************/
  processMsg : function(rorData){
    //Cache the flag that says whether msg was sent
    var status = rorData.success;
    var adpMsg = this;

    //if successful
    if(status === true){
      $('.message-column').removeClass('govuk-form-group--error');
      $('.govuk-textarea').removeClass('govuk-textarea--error');

      $('.message-status p')
        .removeClass()
        .addClass('message-success')
        .text(rorData.statusMessage);

      adpMsg.clearUserMessageBody();
      $('.no-messages').hide();
      $('.file-to-be-uploaded').hide();
      $('#message_attachment').val('');
      this.messagesList.html(rorData.sentMessage).scrollTop(this.messagesList.prop('scrollHeight'));
    //If there was an error
    }else{
      $('.message-column').addClass('govuk-form-group--error');
      $('.govuk-textarea').addClass('govuk-textarea--error');

      $('.message-status p')
        .removeClass()
        .addClass('message-error')
        .text(rorData.statusMessage);
    }
  },

  /**********************************
   Clear the User message so they can
   input another message
   **********************************/
  clearUserMessageBody : function(){
    $('#message_body').val('');
  },

  /********************************
   Upload button functionality
   ********************************/
  selectedFileUpload : function(){
    var self = this;

    self.messageControls.on('change','#message_attachment', function(){
      var $element = $(this);
      var filename = $element.val().replace(/C:\\fakepath\\/i, '');
      var $controls = self.messageControls;

      $controls.find('.filename').text(filename);
      $('.file-to-be-uploaded').show();
    });
  },
  /********************************
   Remove selected file to be uploaded
   ********************************/
  removeSelectedFile : function(){
    this.messageControls.on('click', '.file-to-be-uploaded a',function(event){
      var $element = $(this);

      event.preventDefault();
      $element.closest('.file-to-be-uploaded').hide();
      $('#message_attachment').val('');
    });
  },

  cacheEls: function(){
    this.messagesList = $('.messages-list');
    this.messageControls = $('.message-controls');
  }
};
