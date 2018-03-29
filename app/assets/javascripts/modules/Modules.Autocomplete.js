moj.Modules.Autocomplete = {
  displayNameKey: 'displayName',
  selectSelector: 'select.typeahead',
  wrapperSelector: '.js-typeahead',

  /**
   * init called by moj init routine
   */
  init: function() {
    if (this.doKickoff()) {
      this.typeaheadKickoff();
      this.typeaheadBindEvents();
    }
    this.initAutoCompleteTextFields();
  },

  doKickoff: function() {
    return $(this.selectSelector).length;
  },

  bh: function(data) {
    var self = this;
    if (!data || !data.local) {
      throw Error('Params missing..');
    }
    return new Bloodhound({
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace(self.displayNameKey),
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      identify: function(obj) {
        return obj[self.displayNameKey];
      },
      local: data.local
    });
  },

  sourceWithDefaults: function(q, sync, typeaheadList) {
    if (q === '') {
      sync(typeaheadList.all());
    } else {
      typeaheadList.search(q, sync);
    }
  },

  typeaheadBindEvents: function(selector) {
    var self = this;

    selector = selector || this.wrapperSelector;

    $(selector).on('typeahead:select', 'input.typeahead', function(e, obj) {
      self.typeaheadSetSelectedProp(e, obj[self.displayNameKey]);
    });

    $(selector).on('typeahead:change', 'input.typeahead', function(e, str) {
      self.typeaheadSetSelectedProp(e, str);
    });

    $(selector).on('typeahead:autocomplete', 'input.typeahead', function(e, obj) {
      self.typeaheadSetSelectedProp(e, obj[self.displayNameKey]);
    });
  },

  typeaheadSetSelectedProp: function(e, str) {
    var $wrapper = $(e.delegateTarget);
    var selectedTextString = $wrapper.find('select.typeahead option:selected').text();

    if (str === "" || !str) {
      $wrapper.find('select.typeahead').prop('selectedIndex', 0).change();
      return;
    }

    if (str !== selectedTextString) {
      $wrapper.find('select.typeahead option').filter(function() {
        return $.trim($(this).text()) === $.trim(str);
      }).prop('selected', true).change();
      return;
    }
  },

  typeaheadKickoff: function(selector) {
    var self = this;
    selector = selector || this.selectSelector;

    $(selector).each(function applyTypeahead() {
      var $select = $(this);
      var $input = $('<input />');
      var typeaheadList = self.bh({
        local: self.typeaheadBuildDataFromSelect($select)
      });

      $select.attr('tabindex', -1);

      self.typeaheadPrepInputAndAttach($select, $input).then(function() {
        self.typeaheadInit($input, typeaheadList);
      });
    });
  },

  typeaheadInit: function($input, typeaheadList) {
    var self = this;

    if (!typeaheadList || !$input) {
      throw Error('Missing params');
    }

    if (!$input.typeahead) {
      throw Error('Missing jquery plugin');
    }

    $input.typeahead({
      minLength: 0,
      highlight: true
    }, {
      display: self.displayNameKey,
      limit: 1000,
      source: function(q, sync) {
        return self.sourceWithDefaults(q, sync, typeaheadList);
      },
      templates: {
        empty: [
          '<div class="empty-message">',
          'No Results, please check your spelling',
          '</div>'
        ].join('\n')
      }
    });
  },

  typeaheadPrepInputAndAttach: function($select, $input) {
    var defer = $.Deferred();
    var $parent = $select.parent(); // :(
    var promise1 = this.typeaheadSetInputValueFromDom($select, $input);
    var promise2 = this.typeaheadCopySelectAttrsToInput($select, $input);

    $.when(promise1, promise2).done(function() {
      $parent.find('select.typeahead').after($input);
      defer.resolve();
    });

    return defer.promise();
  },

  typeaheadSetInputValueFromDom: function($select, $input) {
    var defer = $.Deferred();

    $input.val($select.find('option:selected').text());

    defer.resolve($input);
    return defer.promise();
  },

  typeaheadCopySelectAttrsToInput: function($select, $input) {
    var defer = $.Deferred();
    $.each($select.prop('attributes'), function applyAttributes() {
      if (this.name === 'name') {
        return;
      }

      if (this.name === 'id') {
        return $input.attr(this.name, this.value + '_input');
      }
      $input.attr(this.name, this.value);
    });

    $input.removeClass('js-hidden');
    $input.addClass('form-control');
    $input.attr('tabindex', 0);
    $input.attr('autocomplete', 'off');
    defer.resolve($input);

    return defer.promise();
  },

  typeaheadBuildDataFromSelect: function($select) {
    var self = this;
    return $select.find('option').map(function mapOptions() {
      var obj = {};
      if (this.value === '') {
        return;
      }

      obj.id = this.value;
      obj[self.displayNameKey] = this.text;
      return obj;

    }).get();
  },

  // TODO: this should be related to the autocomplete
  // module currently being used. Right now don't really
  // know how to do that easily :(
  suggestionTemplate: function(data) {
    template = '<div class="grid-row offence-item">';
    template += '<div class="column-two-thirds">';
    template += '<a href="#" class="font-xsmall link-grey">' + data.category.description + '</a>'
    template += '<span class="font-xsmall link-grey">&nbsp;&gt;&nbsp;</span>';
    template += '<a href="#" class="font-xsmall link-grey">' + data.band.description + '</a>'
    template += '</br>';
    template += '<span>' + data.description + '</span>';
    template += '</br>';
    template += '<a href="#" class="font-xsmall link-grey">' + data.contrary + '</a>'
    template += '</div>';
    template += '<div class="column-one-third align-right">';
    template += '</br>';
    template += '<a href="#" class="button offence-item-button set-selection" data-field="#claim_offence_id" data-value="' + data.id + '">Select and continue</a>';
    template += '</div></div>';
    return template;
  },

  emptyTemplate: function() {
    var template = '<div class="empty-message">';
    template += 'No Results, please check your spelling';
    template += '</div>';
    return template;
  },

  initAutoCompleteTextFields: function() {
    var self = this;

    $('.typeahead-textfield').each(function() {
      var $element = $(this);
      var data = $element.data();
      var dataSource = new Bloodhound({
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        remote: {
          url: data.url,
          prepare: function(query, settings) {
            // TODO: URL for now already has a base query string
            // hence this just appending extra query params
            settings.url += '&' + $element.attr('name') + '=' + query;
            return settings;
          }
        }
      });
      $element.typeahead({
        hint: false,
        highlight: true,
        menu: $(data.menu),
        minLength: 3
      },
      {
        name: $element.attr('name'),
        display: 'value',
        limit: 100,
        source: dataSource,
        templates: {
          empty: self.emptyTemplate(),
          suggestion: function(data) {
            return self.suggestionTemplate(data);
          }
        }
      });
    });
  }
};
