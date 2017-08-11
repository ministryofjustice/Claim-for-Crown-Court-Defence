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
  }

};