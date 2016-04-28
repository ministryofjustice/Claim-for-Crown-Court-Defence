// AutoComplete plugin
// Dependencies: jQuery

(function($){
  $.fn.AutoComplete = function( options ) {
    
    var self = this;
    
    this.init = function(select) {
      if(!select)
        return false;

      var id = $(select).attr('id'),
        input = Awesomplete.$.create('input');
      $(input).addClass('form-control').attr('id', id+'_autocomplete');
      input.disabled = $(select).attr('disabled')? true : false;
      select.parentElement.insertBefore(input, select);
      select.setAttribute("hidden", "");

      this.copySelectedValue(input, select);

      var awesompleteElement = new Awesomplete(input, {
        list: this.createDataList(select.options),
        autoFirst: true,
        minChars: 0,
        maxItems: 999
      });

      this.bindEvents(input, select);

      Awesomplete.$.bind(input, {
        'awesomplete-selectcomplete': function(){
          var selectedItems = Awesomplete.$$("option", select).filter(function(elem){
            return  elem.text === input.value;
          });
          if(selectedItems.length > 0){
            $(select).val(selectedItems[0].value).change();
          }
        },
        'awesomplete-open': function(){
          awesompleteElement.opened = true;
        },
        'blur': function(){
          self.copySelectedValue(input, select);
        },
        'mousedown': function(e){
          awesompleteElement.lastClick = e.target;
          this.value = '';
          self.open(awesompleteElement);
        },
        'focus': function(e){
          if (e.target == awesompleteElement.lastClick) { // Click
            return;
          } else { // Tab
            this.value = '';
            self.open(awesompleteElement); 
          }
          awesompleteElement.lastClick = null;
        }
      });     
    };

    this.open = function(awesompleteElement){
      if (awesompleteElement.ul.childNodes.length === 0) {
        awesompleteElement.minChars = 0;
        awesompleteElement.evaluate();
      }
      else if (awesompleteElement.ul.hasAttribute('hidden')) {
        awesompleteElement.open();
      }
      else {
        awesompleteElement.close();
      }
    };

    this.createDataList = function(list){
      var dataList = [];
      for(var i = 0;i<list.length;i++){
        var item = {label: list[i].text, value: list[i].text};
        dataList.push(list[i].text);
      }
      return dataList;
    };

    this.bindEvents = function(input, select){
      $(input).on('change', function(){
        var selectedItems = Awesomplete.$$("option", select).filter(function(elem){
          return  elem.text === input.value;
        });
        if(selectedItems.length > 0){
          $(select).val(selectedItems[0].value).change();
        }
      });
      $(select).on('change', function(){
        self.copySelectedValue(input, select);
      });
    };

    this.copySelectedValue = function(input, select){
      if(select.selectedIndex > -1){
        input.value = $(select).find('option:selected').text();
      }
    };

    this.init(this[0]);
      
  };
}(jQuery));

$(function (){
  $('select.autocomplete').each(function(i,select){
    $(select).AutoComplete();
  });
});