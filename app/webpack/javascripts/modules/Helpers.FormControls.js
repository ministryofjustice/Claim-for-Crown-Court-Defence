/* global Option */

// Helpers.FormControls.getSelect
(function (exports, $) {
  const Module = exports.Helpers.FormControls || {}

  function getSelect (options) {
    const _options = options || ''
    return ['<select name="" id="">', _options, '</select>'].join('')
  }

  Module.select = {
    getSelect
  }

  exports.Helpers.FormControls = Module
}(moj, jQuery));

// Helpers.FormControls.getInput
(function (exports, $) {
  const Module = exports.Helpers.FormControls || {}

  function getInput (config) {
    const _config = $.extend({}, {
      type: 'text',
      classes: '',
      id: '',
      value: '',
      name: ''
    }, config)
    return ['<input class="form-control ' + _config.classes + '" type="' + _config.type + '" name="' + _config.name + '" id="' + _config.id + '" value="' + _config.value + '" />'].join('')
  }

  Module.input = {
    getInput
  }

  exports.Helpers.FormControls = Module
}(moj, jQuery));

// Helpers.FormControls.getOptions
(function (exports, $) {
  const Module = exports.Helpers.FormControls || {}

  function getOptions (collection, selected) {
    const def = $.Deferred()
    const optionsArray = []
    let option
    selected = selected || {
      value: 'miss-match'
    }
    if (!collection) {
      throw Error('Missing param: collection')
    }

    optionsArray.push(new Option('Please select', '').outerHTML)
    const collectionSize = collection.length

    collection.forEach(function (obj, idx) {
      option = new Option(obj.name, obj.id, (obj[selected.prop] === selected.value))
      option.dataset.postcode = obj.postcode
      optionsArray.push(option.outerHTML)

      if (collectionSize - 1 === idx) {
        def.resolve(optionsArray)
      }
    })
    return def.promise()
  }

  Module.selectOptions = {
    getOptions
  }

  exports.Helpers.FormControls = Module
}(moj, jQuery));

// Helpers.FormControls.getGovUkDate
(function (exports, $) {
  const Module = exports.Helpers.FormControls || {}

  function getGovUkDate (context) {
    const dateArray = []
    $(context).first('.gov_uk_date:visible').find('input[type=number]').is(function (index, element) {
      dateArray.push($(element).val())
    })

    return new Date(dateArray.reverse().join('-'))
  }

  Module.govUkDate = {
    getGovUkDate
  }

  exports.Helpers.FormControls = Module
}(moj, jQuery));

(function (exports, $) {
  let Module = exports.Helpers.FormControls || {}

  Module = {
    select: Module.select,
    selectOptions: Module.selectOptions,
    input: Module.input,
    getInput: Module.input.getInput,
    getSelect: Module.select.getSelect,
    getOptions: Module.selectOptions.getOptions,
    getGovUkDate: Module.govUkDate.getGovUkDate
  }

  exports.Helpers.FormControls = Module
}(moj, jQuery))
