(function($){
  $.fn.repeatElement = function( options ) {
    $.fn.repeatElement.defaults = {
      removeText: 'Remove'
    };

    var self = this,
      regex = /^(.+?)(\d+)$/i;;
    options = $.extend( $.fn.repeatElement.defaults, options );

    this.on('click', function(e){
      e.preventDefault();
      e.stopPropagation();
      self.currentTarget = $(e.currentTarget);
      self.init(e);
    });

    this.init = function(){
      var currentEl = this.setTarget(this.currentTarget);
      var newEl = this.createElement(currentEl);
      this.insertElement(currentEl, newEl);
    };

    this.setTarget = function(el){
      var target = $(el).data('target')
      return $('.'+target);
    };

    this.createElement = function(el){
      this.newElement = this.cloneTarget(el.first());
      this.newElement.append(this.createRemoveLink());
      this.clearInputs(this.newElement);
      this.updateIDs(this.newElement);
      return this.newElement;
    };

    this.cloneTarget = function(el){
      return el.clone(true);
    };

    this.clearInputs = function(element){
      $('input, select, textarea', element).each(function(i, e){
        $(this).val('').prop('checked', false);
      });
    };

    this.updateIDs = function(element){
      $('*', element).each(function(){
        var arr = ['id', 'name', 'htmlFor'];
        for(var i=0;i<arr.length;i++){
          var arrName = this[arr[i]];
          if(arrName){
            if (/\[(\d+)\]/.test(arrName)){
              arrName = arrName.replace(/\[(\d+)\]/, function(str,p1){
                return '[' + (parseInt(p1,10)+1) + ']';
              });
            }
            if (/\_(\d+)\_/.test(arrName)){
              arrName = arrName.replace(/\_(\d+)\_/, function(str,p1){
                return '_' + (parseInt(p1,10)+1) + '_';
              });
            }
            this[arr[i]] = arrName;
          }
        }
      });
    };

    this.createRemoveLink = function(){
      var self = this;
      return $('<a/>')
        .attr('href', '#')
        .addClass('js-remove-fields')
        .html(this.currentTarget.data('remove-text'))
        .on('click', function(e){
          e.preventDefault();
          e.stopPropagation();
          self.deleteElement($(e.currentTarget));
        });
    };

    this.insertElement = function(currentEl, newEl){
      newEl.insertAfter(currentEl.last());
      this.success();
    };

    this.deleteElement = function(el){
      el.parent().remove();
    };

    this.success = function(){
      options.success.call(this, this.newElement);
    };
  };
}(jQuery));


$(function (){
  $('.js-repeat-element').repeatElement({
    success: function(insertedElement) {
      $('input:first', insertedElement).focus();
    }
  });
});