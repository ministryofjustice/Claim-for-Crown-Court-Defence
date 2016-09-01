//Based off the example given here http://oaa-accessibility.org/example/37/
moj.Modules.Accordion = {
  //Store our keycodes
  keyCodes: {},

  //Set the keycodes that this Accordion will use
  setKeyCodes: function() {
    // Define values for keycodes
    this.keyCodes.tab = 9;
    this.keyCodes.enter = 13;
    this.keyCodes.esc = 27;

    this.keyCodes.space = 32;
    this.keyCodes.pageup = 33;
    this.keyCodes.pagedown = 34;
    this.keyCodes.end = 35;
    this.keyCodes.home = 36;

    this.keyCodes.left = 37;
    this.keyCodes.up = 38;
    this.keyCodes.right = 39;
    this.keyCodes.down = 40;
  },

  $tab: {}, // the selected tab - if one is selected

  $tabs: {}, //// Array of panel tabs.

  accordionId: 'claim-accordion',

  $panel: {}, // store the jQuery object for the panel

  $panels: {},

  curNdx: '', // Current index

  cacheEl: function() {
    this.$panel = $('#' + this.accordionId);
    this.$tabs = this.$panel.find('.tab'); // Array of panel tabs.
    this.$panels = this.$panel.children('.panel'); // Array of panels.
    this.lastHeadingIndex = this.$tabs.length - 1;
    this.setKeyCodes();
  },

  init: function() {

    this.cacheEl();

    // Bind event handlers
    this.bindHandlers();

    // add aria attributes to the panels
    this.$panels.attr('aria-hidden', 'true');

    // get the selected tab
    this.$tab = this.$tabs.filter('[aria-selected="true"]');
    if (this.$tab === undefined) {
      this.$tab = this.$tabs.first();
    }

    // show the panel that the selected tab controls and set aria-hidden to false
    this.$panel.find('#' + this.$tab.attr('aria-controls')).attr('aria-hidden', 'false');
  },

  //
  // Function switchTabs() is a member function to give focus to a new tab or accordian header.
  // If it's a tab panel, the currently displayed panel is hidden and the panel associated with the new tab
  // is displayed.
  //
  // @param ($curTab obj) $curTab is the jQuery object of the currently selected tab
  //
  // @param ($newTab obj) $newTab is the jQuery object of new tab to switch to
  //
  // @return N/A
  //
  switchTabs: function($curTab, $newTab) {

    // Remove the highlighting from the current tab
    $curTab.removeClass('focus')
      // remove tab from the tab order and update its aria-selected attribute
      .attr('tabindex', '-1')
      .attr('aria-selected', 'false');

    // Highlight the new tab and update its aria-selected attribute
    $newTab.attr('aria-selected', 'true')
      // Make new tab navigable
      .attr('tabindex', '0')
      // give the new tab focus
      .focus();
  },

  //
  // Function togglePanel() is a member function to display or hide the panel
  // associated with an accordian header. Function also binds a keydown handler to the focusable items
  // in the panel when expanding and unbinds the handlers when collapsing.
  //
  // @param ($tab obj) $tab is the jQuery object of the currently selected tab
  //
  // @return N/A
  //
  togglePanel: function($tab) {

    var $panel = this.$panel.find('#' + $tab.attr('aria-controls'));

    if ($panel.attr('aria-hidden') == 'true') {
      $panel.attr('aria-hidden', 'false');

      // update the aria-expanded attribute
      $tab.attr('aria-expanded', 'true');
    } else {
      $panel.attr('aria-hidden', 'true');
      $panel.slideUp(100);

      // update the aria-expanded attribute
      $tab.attr('aria-expanded', 'false');
    }
  },


  //
  // Function bindHandlers() is a member function to bind event handlers for the tabs
  //
  // @return N/A
  //
  bindHandlers: function() {

    var thisObj = this; // Store the this pointer for reference

    //////////////////////////////
    // Bind handlers for the tabs / accordian headers

    // bind a tab keydown handler
    this.$tabs.on('keydown', function(e) {
        return thisObj.handleTabKeyDown($(this), e);
      })
      .on('keypress', function(e) {
        // bind a tab keypress handler
        return thisObj.handleTabKeyPress($(this), e);
      })
      .on('click', function(e) {
        // bind a tab click handler
        return thisObj.handleTabClick($(this), e);
      })
      .on('focus', function() {
        // bind a tab focus handler
        return thisObj.handleTabFocus();
      })
      .on('blur', function() {
        // bind a tab blur handler
        return thisObj.handleTabBlur();
      });

  },


  //
  // Function handleTabKeyDown() is a member function to process keydown events for a tab
  //
  // @param ($tab obj) $tab is the jquery object of the tab being processed
  //
  // @paran (e obj) e is the associated event object
  //
  // @return (boolean) Returns true if propagating; false if consuming event
  //
  handleTabKeyDown: function($tab, e) {

    //current heading position
    this.curNdx = this.$tabs.index($tab);

    if (e.altKey) {
      // do nothing
      return true;
    }

    var $newTab; // the new tab to switch to

    switch (e.keyCode) {
      case this.keyCodes.enter:
      case this.keyCodes.space:
        {

          // display or collapse the panel
          this.togglePanel($tab);
          break;
        }
      case this.keyCodes.left:
      case this.keyCodes.up:
        {

          if (!e.ctrlKey) {

            $newTab = this.moveToHeading(this.curNdx, 'up');

            // switch to the new tab
            this.switchTabs($tab, $newTab);
          }
          break;
        }
      case this.keyCodes.right:
      case this.keyCodes.down:
        {

          $newTab = this.moveToHeading(this.curNdx, 'down');

          // switch to the new tab
          this.switchTabs($tab, $newTab);
          break;
        }
      case this.keyCodes.home:
        {
          // switch to the first tab
          this.switchTabs($tab, this.moveToHeading(this.lastHeadingIndex));
          break;
        }
      case this.keyCodes.end:
        {

          // switch to the last tab
          this.switchTabs($tab, this.$tabs.last());

        }
    }

    e.stopPropagation();
    return false;
  },

  moveToHeading: function(index, direction) {
    if (index === 0 && direction == 'up') {
      // tab is the first one:
      // set return the last heading
      return this.$tabs.last();
      //move to previous
    } else if (index > 0 && index <= this.$tabs.length - 1 && direction == 'up') {
      // set return the previous heading
      return this.$tabs.eq(index - 1);
    } else if (index > 0 && index <= this.$tabs.length - 1 && direction == 'down') {
      // set return the next heading
      return this.$tabs.eq(index + 1);

    } else if (index === this.lastHeadingIndex) {
      // heading is the last one:
      // set heading to first tab
      return this.$tabs.first();
    } else {
      // set newTab to next tab
      return this.$tabs.eq(index + 1);
    }
  },

  //
  // Function handleTabKeyPress() is a member function to process keypress events for a tab.
  //
  //
  // @param ($tab obj) $tab is the jquery object of the tab being processed
  //
  // @paran (e obj) e is the associated event object
  //
  // @return (boolean) Returns true if propagating; false if consuming event
  //
  handleTabKeyPress: function($tab, e) {

    if (e.altKey) {
      // do nothing
      return true;
    }

    switch (e.keyCode) {
      case this.keyCodes.enter:
      case this.keyCodes.space:
      case this.keyCodes.left:
      case this.keyCodes.up:
      case this.keyCodes.right:
      case this.keyCodes.down:
      case this.keyCodes.home:
      case this.keyCodes.end:
        {
          e.stopPropagation();
          return false;
        }
      case this.keyCodes.pageup:
      case this.keyCodes.pagedown:
        {

          // The tab keypress handler must consume pageup and pagedown
          // keypresses to prevent Firefox from switching tabs
          // on ctrl+pageup and ctrl+pagedown

          if (!e.ctrlKey) {
            return true;
          }

          e.stopPropagation();
          return false;
        }
    }

    return true;

  },


  //
  // Function handleTabClick() is a member function to process click events for tabs
  //
  // @param ($tab object) $tab is the jQuery object of the tab being processed
  //
  // @paran (e object) e is the associated event object
  //
  // @return (boolean) returns false
  //
  handleTabClick: function($tab, e) {

    // make clicked tab navigable
    $tab.attr('tabindex', '0').attr('aria-selected', 'true');

    // remove all tabs from the tab order and update their aria-selected attribute
    this.$tabs.not($tab).attr('tabindex', '-1').attr('aria-selected', 'false');

    // Expand the new panel
    this.togglePanel($tab);

    e.stopPropagation();
    return false;
  },


  //
  // Function handleTabFocus() is a member function to process focus events for tabs
  //
  // @param ($tab object) $tab is the jQuery object of the tab being processed
  //
  // @paran (e object) e is the associated event object
  //
  // @return (boolean) returns true
  //
  handleTabFocus: function() {

    // Add the focus class to the tab
    this.$tab.addClass('focus');

    return true;
  },


  //
  // Function handleTabBlur() is a member function to process blur events for tabs
  //
  // @param ($tab object) $tab is the jQuery object of the tab being processed
  //
  // @paran (e object) e is the associated event object
  //
  // @return (boolean) returns true
  //
  handleTabBlur: function() {

    // Remove the focus class to the tab
    this.$tab.removeClass('focus');

    return true;
  }

};


// focusable is a small jQuery extension to add a :focusable selector. It is used to
// get a list of all focusable elements in a panel. Credit to ajpiano on the jQuery forums.
//
$.extend($.expr[':'], {
  focusable: function(element) {
    var nodeName = element.nodeName.toLowerCase();
    var tabIndex = $(element).attr('tabindex');

    // the element and all of its ancestors must be visible
    if (($(element)[(nodeName === 'area' ? 'parents' : 'closest')](':hidden').length) == -true) {
      return false;
    }

    // If tabindex is defined, its value must be greater than 0
    if (!isNaN(tabIndex) && tabIndex < 0) {
      return false;
    }

    // if the element is a standard form control, it must not be disabled
    if (/input|select|textarea|button|object/.test(nodeName) === true) {

      return !element.disabled;
    }

    // if the element is a link, href must be defined
    if ((nodeName == 'a' || nodeName == 'area') === true) {

      return (element.href.length > 0);
    }

    // this is some other page element that is not normally focusable.
    return false;
  }
});