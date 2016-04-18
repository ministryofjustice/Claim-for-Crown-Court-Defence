// AutoComplete plugin
// Dependencies: jQuery

(function($){
  $.fn.AutoComplete = function( options ) {
    
    var self = this;
    
    this.init = function(select) {
      
      var id = $(select).attr('id'),
        input = Awesomplete.$.create('input');
      $(input).addClass('form-control').attr('id', id+'_autocomplete');
      input.disabled = $(select).attr('disabled')? true : false;
      select.parentElement.insertBefore(input, select);
      select.setAttribute("hidden", "");

      var dataList = [],
        list = select.options;

      for(var i = 0;i<list.length;i++){
        var item = {label: list[i].text, value: list[i].text};
        dataList.push(list[i].text);
      }

      this.copySelectedValue(input, select);

      var awesompleteElement = new Awesomplete(input, {
        list: dataList,
        autoFirst: true
      });

      Awesomplete.$.bind(input, {
        'awesomplete-selectcomplete': function(){
          var selectedItems = Awesomplete.$$("option", select).filter(function(elem){
            return  elem.text === input.value;
          });
          if(selectedItems.length > 0){
            $(select).val(selectedItems[0].value).change();
          }
        },
        'blur': function(){
          self.copySelectedValue(input, select);
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
