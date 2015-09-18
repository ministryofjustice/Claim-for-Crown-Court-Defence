/*********************************************
##     ## ########  ######   ######     ###     ######   ########  ######
###   ### ##       ##    ## ##    ##   ## ##   ##    ##  ##       ##    ##
#### #### ##       ##       ##        ##   ##  ##        ##       ##
## ### ## ######    ######   ######  ##     ## ##   #### ######    ######
##     ## ##             ##       ## ######### ##    ##  ##             ##
##     ## ##       ##    ## ##    ## ##     ## ##    ##  ##       ##    ##
##     ## ########  ######   ######  ##     ##  ######   ########  ######

Notes: JS functions relating to messages
*********************************************/
"use strict";

var adp = adp || {};

adp.messaging = {
  init :function(){
    if($('.messages-list').length > 0){
      $('.messages-list').scrollTop($('.messages-list').prop("scrollHeight"));
    }
  },
  /******************************
  rorData = Data object received from Ruby on Rails
  ******************************/
  processMsg : function(rorData){
    //Cache the flag that says whether msg was sent
    var status = rorData.success,
    adpMsg = this;

    //if successful
    if(status === true){
      $('.message-success').text(rorData.statusMessage);
      adpMsg.clearErrorMsg();
      adpMsg.toggleStatusBar();

      adpMsg.clearUserMessageBody();
      $('.no-messages').hide();
      console.log($(".messages-list").prop("scrollHeight"));
      $('.messages-list').append(rorData.sentMessage).scrollTop($('.messages-list').prop("scrollHeight"));
    //If there was an error
    }else{
      $('.message-error').text(rorData.statusMessage);
      adpMsg.clearSuccessMsg();
      adpMsg.toggleStatusBar();
    }
  },
  /**********************************
  Toggles the show/hide of Message status
  **********************************/
  //toggleStatusBar
  toggleStatusBar : function(){
    //Slide in the status
    $('.message-status')
      .animate({left:'0px'},{
        complete : function(){

          console.log('slide done');
          setTimeout(function(){
            $('.message-status').animate({left: '-9999px'});
          },5000);
        }
      })
  },
  /**********************************
  Clear the User message so they can
  input another message
  **********************************/
  clearUserMessageBody : function(){
    $('#message_body').val('');
  },
  /*********************************
  Clear Error Message
  *********************************/
  clearErrorMsg : function(){

    console.log('clear errors');
    $('.message-error').text('');
  },
  /*********************************
  Clear success Message
  *********************************/
  clearSuccessMsg : function(){
    $('.message-success').text('');
  }
};
