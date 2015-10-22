"use strict";

var adp = adp || {};

adp.tableRowClick = {
  $selector: $('.js-checkbox-table'),

  init : function() {
    if($(adp.tableRowClick.$selector).length) {
      adp.tableRowClick.$selector.each(function(index, element) {
        adp.tableRowClick.attach(element);
      });
    }
  },
  attach : function(element) {
    $(element).on('click', 'tr', function(event) {
      var $element = $(this);
      var $checkbox = $element.find(':checkbox');
      var newState = $checkbox.is(':checked') ? false : true;

      $checkbox.prop('checked', newState)
    });
  }
};
