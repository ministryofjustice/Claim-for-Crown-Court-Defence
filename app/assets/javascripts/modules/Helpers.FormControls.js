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

  function getOptions(collection) {
    var def = $.Deferred();
    var optionsArray = [];
    var collectioSize;
    if (!collection) {
      throw Error('Missing param: collection');
    }

    optionsArray.push('<option value="">Please select</option>');
    collectionSize = collection.length;

    collection.forEach(function(obj, idx) {
      optionsArray.push('<option data-postcode="' + obj.postcode + '" value="' + obj.id + '">' + obj.name + '</option>');
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
