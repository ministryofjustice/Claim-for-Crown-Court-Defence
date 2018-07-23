// Helpers.FormControls.getSelect
(function(exports, $) {
  var Module = exports.Helpers.FormControls || {};

  function getSelect(options) {
    var _options = options || '';
    return ['<select name="" id="">', _options, '</select>'].join('');
  }

  Module.select = {
    getSelect: getSelect
  };

  exports.Helpers.FormControls = Module;
}(moj, jQuery));

// Helpers.FormControls.getOptions
(function(exports, $) {
  var Module = exports.Helpers.FormControls || {};

  function getOptions(collection, selected) {
    var def = $.Deferred();
    var optionsArray = [];
    var collectioSize;
    selected = selected || {value: 'miss-match'};
    if (!collection) {
      throw Error('Missing param: collection');
    }

    optionsArray.push(new Option('Please select', '').outerHTML);
    collectionSize = collection.length;

    collection.forEach(function(obj, idx) {

      var option = new Option(obj.name, obj.id, (obj[selected.prop] === selected.value));

      option.dataset.postcode  = obj.postcode;
      optionsArray.push(option.outerHTML);

      if (collectionSize - 1 === idx) {
        def.resolve(optionsArray);
      }
    });
    return def.promise();
  }

  Module.selectOptions = {
    getOptions: getOptions
  };

  exports.Helpers.FormControls = Module;
}(moj, jQuery));

(function(exports, $) {
  var Module = exports.Helpers.FormControls || {};

  Module = {
    select: Module.select,
    getSelect: Module.select.getSelect,
    selectOptions: Module.selectOptions,
    getOptions: Module.selectOptions.getOptions,
  };

  exports.Helpers.FormControls = Module;
}(moj, jQuery));
