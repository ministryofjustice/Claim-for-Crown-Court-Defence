(function(exports, $) {
  var Module = exports.Helpers.Autocomplete || {};

  //
  Module.new = function(element, options) {
    var selectElement, config;
    if (!(typeof element === 'string' || element instanceof String)) {
      throw new Error('Param: `element` is missing or not a string');
    }
    if ($(element).length !== 1) {
      throw new Error('No element found. Usage: `#selector`');
    }

    selectElement = document.querySelector(element);

    // Merge options and defaults
    config = $.extend({}, {
      selectElement: selectElement,

      // This setting will auto select the top result
      autoselect: true,

      // Overwriting this method to be able to $.publish() the event
      onConfirm: function(query) {

        // filter the select options, return the matching one
        var requestedOption = [].filter.call(selectElement.options, function(option) {
          return (option.textContent || option.innerText) === query;
        })[0];

        // if there is a match, set the `selected` property
        if (requestedOption) {
          requestedOption.selected = true;
        }

        // Publish the onConfirm event when a `query` is present
        if (query) {
          $.publish('/onConfirm/' + selectElement.id + '/', $.extend({
            query: query,
            selectElement: selectElement
          }, $(requestedOption).data()));
        }
      }
    }, options);

    // Initialise using accessibleAutocomplete.enhanceSelectElement
    accessibleAutocomplete.enhanceSelectElement(config);
  };

  exports.Helpers.Autocomplete = Module;
}(moj, jQuery));
