"use strict";

var adp = adp || {};

adp.tableRowClick = {
  $selector: null,

  init : function(table_id) {
    if($('#' + table_id).length) {
      adp.tableRowClick.$selector = '#' + table_id;
      adp.tableRowClick.attach();
    }
  },
  attach : function() {
    $(adp.tableRowClick.$selector + ' tr').click(function(event) {
      if (event.target.type !== 'checkbox') {
        event.preventDefault();
        event.stopPropagation();
        $(':checkbox', this).trigger('click');
      }
    });
  }
};
