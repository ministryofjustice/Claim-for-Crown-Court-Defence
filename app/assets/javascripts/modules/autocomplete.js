// Autocomplete module
// Dependencies: jQuery



(function(){

  function copySelectedValue(input, select){
    if(select.selectedIndex > -1){
      input.value = $(select).find('option:selected').text();//select.options[select.selectedIndex].text;
    }
  }
  
  function init() {
    Awesomplete.$$("select.autocomplete").forEach(function (select) {

      var input = Awesomplete.$.create('input');
      $(input).addClass('form-control');
      input.disabled = $(select).attr('disabled')? true : false;
      select.parentElement.insertBefore(input, select);

      var dataList = [],
        list = select.options;

      for(var i = 0;i<list.length;i++){
        var item = {label: list[i].text, value: list[i].text};
        dataList.push(list[i].text);
      }
      select.setAttribute("hidden", "");

      console.log($(select).find('option:selected').text());

      copySelectedValue(input, select);

      var awesompleteElement = new Awesomplete(input, {
        list: dataList,
        autoFirst: true
      });

      Awesomplete.$.bind(input, {
        'awesomplete-selectcomplete': function(){
          var selectedItems = Awesomplete.$$("option", select).filter(function(elem){
            return  elem.text === input.value
          });
          if(selectedItems.length > 0){
            // select.value = selectedItems[0].value;
            $(select).val(selectedItems[0].value).change()
          }
        },
        'blur': function(){
          copySelectedValue(input, select);
        }
      });
      
    });
  }

  // DOM already loaded?
  if (document.readyState !== "loading") {
    init();
  } else {
    // Wait for it
    document.addEventListener("DOMContentLoaded", init);
  }
})();