//Based off the example given here http://oaa-accessibility.org/example/37/
moj.Modules.Accordion = {
  //Store our keycodes
  keyCodes : {},

  //Set the keycodes that this Accordion will use
  setKeyCodes : function (){
    // Define values for keycodes
    this.keyCodes.tab        = 9;
    this.keyCodes.enter      = 13;
    this.keyCodes.esc        = 27;

    this.keyCodes.space      = 32;
    this.keyCodes.pageup     = 33;
    this.keyCodes.pagedown   = 34;
    this.keyCodes.end        = 35;
    this.keyCodes.home       = 36;

    this.keyCodes.left       = 37;
    this.keyCodes.up         = 38;
    this.keyCodes.right      = 39;
    this.keyCodes.down       = 40;
  },

  $tab : {}, // the selected tab - if one is selected

  $tabs: {}, //// Array of panel tabs.

  accordionId : 'claim-accordion',

  $panel : {}, // store the jQuery object for the panel

  $panels :{},

  curNdx : '', // Current index

  cacheEl: function (){
    this.$panel = $('#' + this.accordionId);
    this.$tabs = this.$panel.find('.tab'); // Array of panel tabs.
    this.$panels = this.$panel.children('.panel'); // Array of panels.
    this.setKeyCodes();
  },


  //
  // tabpanel() is a class constructor to create a ARIA-enabled tab panel widget.
  //
  // @param (id string) id is the id of the div containing the tab panel.
  //
  // @param (accordian boolean) accordian is true if the tab panel should operate
  //         as an accordian; false if a tab panel
  //
  // @return N/A
  //
  // Usage: Requires a div container and children as follows:
  //
  //         1. tabs/accordian headers have class 'tab'
  //
  //         2. panels are divs with class 'panel'
  //

  tabpanel : function (accordian){

    // define the class properties

    this.panel_id = this.accordionId; // store the id of the containing div
    this.accordian = accordian; // true if this is an accordian control


  },

  init : function() {

    this.cacheEl();

    this.tabpanel(true);

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
  switchTabs : function($curTab, $newTab) {

    // Remove the highlighting from the current tab
    $curTab.removeClass('focus');

    // remove tab from the tab order and update its aria-selected attribute
    $curTab.attr('tabindex', '-1').attr('aria-selected', 'false');


    // Highlight the new tab and update its aria-selected attribute
    $newTab.attr('aria-selected', 'true');

    // If activating new tab/panel, swap the displayed panels
    if (this.accordian === false) {
      // hide the current tab panel and set aria-hidden to true
      this.$panel.find('#' + $curTab.attr('aria-controls')).attr('aria-hidden', 'true');

      // update the aria-expanded attribute for the old tab
      $curTab.attr('aria-expanded', 'false');

      // show the new tab panel and set aria-hidden to false
      this.$panel.find('#' + $newTab.attr('aria-controls')).attr('aria-hidden', 'false');

      // update the aria-expanded attribute for the new tab
      $newTab.attr('aria-expanded', 'true');

    }

    // Make new tab navigable
    $newTab.attr('tabindex', '0');

    // give the new tab focus
    $newTab.focus();
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
  togglePanel : function ($tab) {

    var $panel = this.$panel.find('#' + $tab.attr('aria-controls'));

    if ($panel.attr('aria-hidden') == 'true') {
      $panel.attr('aria-hidden', 'false');
      $tab.find('img').attr('src', 'http://www.oaa-accessibility.org/media/examples/images/expanded.gif').attr('alt', 'expanded');

      // update the aria-expanded attribute
      $tab.attr('aria-expanded', 'true');
    } else {
      $panel.attr('aria-hidden', 'true');
      $panel.slideUp(100);
      $tab.find('img').attr('src', 'http://www.oaa-accessibility.org/media/examples/images/contracted.gif').attr('alt', 'collapsed');

      // update the aria-expanded attribute
      $tab.attr('aria-expanded', 'false');
    }
  },


  //
  // Function bindHandlers() is a member function to bind event handlers for the tabs
  //
  // @return N/A
  //
  bindHandlers : function () {

    var thisObj = this; // Store the this pointer for reference

    //////////////////////////////
    // Bind handlers for the tabs / accordian headers

    // bind a tab keydown handler
    this.$tabs.keydown(function(e) {
      return thisObj.handleTabKeyDown($(this), e);
    });

    // bind a tab keypress handler
    this.$tabs.keypress(function(e) {
      return thisObj.handleTabKeyPress($(this), e);
    });

    // bind a tab click handler
    this.$tabs.click(function(e) {
      return thisObj.handleTabClick($(this), e);
    });

    // bind a tab focus handler
    this.$tabs.focus(function() {
      return thisObj.handleTabFocus();
    });

    // bind a tab blur handler
    this.$tabs.blur(function() {
      return thisObj.handleTabBlur();
    });

    /////////////////////////////
    // Bind handlers for the panels

    // bind a keydown handlers for the panel focusable elements
    this.$panels.keydown(function(e) {
      return thisObj.handlePanelKeyDown($(this), e);
    });

    // bind a keypress handler for the panel
    this.$panels.keypress(function(e) {
      return thisObj.handlePanelKeyPress($(this), e);
    });

    // bind a panel click handler
    this.$panels.click(function() {
      return thisObj.handlePanelClick();
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
  handleTabKeyDown : function($tab, e) {

    if (e.altKey) {
      // do nothing
      return true;
    }

    var $newTab; // the new tab to switch to

    switch (e.keyCode) {
    case this.keyCodes.enter:
    case this.keyCodes.space: {

      // Only process if this is an accordian widget
      if (this.accordian === true) {
        // display or collapse the panel
        this.togglePanel($tab);

        e.stopPropagation();
        return false;
      }

      return true;
    }
    case this.keyCodes.left:
    case this.keyCodes.up: {

      if (e.ctrlKey) {
        // Ctrl+arrow moves focus from panel content to the open
        // tab/accordian header.
      } else {
        var curNdx = this.$tabs.index($tab);

        if (curNdx === 0) {
          // tab is the first one:
          // set newTab to last tab
          $newTab = this.$tabs.last();
        }
        else {
          // set newTab to previous
          $newTab = this.$tabs.eq(curNdx - 1);
        }

        // switch to the new tab
        this.switchTabs($tab, $newTab);
      }

      e.stopPropagation();
      return false;
    }
    case this.keyCodes.right:
    case this.keyCodes.down: {

      this.curNdx = this.$tabs.index($tab);

      if (this.curNdx == this.$tabs.length-1) {
        // tab is the last one:
        // set newTab to first tab
        $newTab = this.$tabs.first();
      } else {
        // set newTab to next tab
        $newTab = this.$tabs.eq(this.curNdx + 1);
      }

      // switch to the new tab
      this.switchTabs($tab, $newTab);

      e.stopPropagation();
      return false;
    }

    case this.keyCodes.home: {
      // switch to the first tab
      this.switchTabs($tab, this.$tabs.first());

      e.stopPropagation();
      return false;
    }
    case this.keyCodes.end: {

      // switch to the last tab
      this.switchTabs($tab, this.$tabs.last());

      e.stopPropagation();
      return false;
    }
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
  handleTabKeyPress : function ($tab, e) {

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
    case this.keyCodes.end: {
      e.stopPropagation();
      return false;
    }
    case this.keyCodes.pageup:
    case this.keyCodes.pagedown: {

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
  handleTabClick : function($tab, e) {

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
  handleTabFocus: function (){

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
  handleTabBlur: function (){

    // Remove the focus class to the tab
    this.$tab.removeClass('focus');

    return true;

  },



  /////////////////////////////////////////////////////////
  // Panel Event handlers
  //

  //
  // Function handlePanelKeyDown() is a member function to process keydown events for a panel
  //
  // @param ($panel obj) $panel is the jquery object of the panel being processed
  //
  // @paran (e obj) e is the associated event object
  //
  // @return (boolean) Returns true if propagating; false if consuming event
  //
  handlePanelKeyDown : function($panel, e) {

    if (e.altKey) {
      // do nothing
      return true;
    }

    switch (e.keyCode) {
    case this.keyCodes.tab: {
      var $focusable = $panel.find(':focusable');
      var curNdx = $focusable.index($(e.target));
      var panelNdx = this.$panels.index($panel);
      var numPanels = this.$panels.length;

      if (e.shiftKey) {
        // if this is the first focusable item in the panel
        // find the preceding expanded panel (if any) that has
        // focusable items and set focus to the last one in that
        // panel. If there is no preceding panel or no focusable items
        // do not process.
        if (curNdx === 0 && panelNdx > 0) {

          // Iterate through previous panels until we find one that
          // is expanded and has focusable elements
          //
          for (var ndx = panelNdx - 1; ndx >= 0; ndx--) {

            var $prevPanel = this.$panels.eq(ndx);
            var $prevTab = $('#' + $prevPanel.attr('aria-labelledby'));

            // get the focusable items in the panel
            $focusable.length = 0;
            $focusable = $prevPanel.find(':focusable');

            if ($focusable.length > 0) {
              // there are focusable items in the panel.
              // Set focus to the last item.
              $focusable.last().focus();

              // Reset the aria-selected state of the tabs
              this.$tabs.attr('aria-selected', 'false');

              // Set that associated tab's aria-selected state to true
              $prevTab.attr('aria-selected', 'true');
            }
          }
          e.stopPropagation();
          return false;
        }

      } else if(panelNdx < numPanels) {

        // if this is the last focusable item in the panel
        // find the nearest following expanded panel (if any) that has
        // focusable items and set focus to the first one in that
        // panel. If there is no preceding panel or no focusable items
        // do not process.
        if (curNdx == $focusable.length - 1) {

          // Iterate through following panels until we find one that
          // is expanded and has focusable elements
          //
          for (var panelIndex = panelNdx + 1; panelIndex < numPanels; panelIndex++) {

            var $nextPanel = this.$panels.eq(panelIndex);
            var $nextTab = $('#' + $nextPanel.attr('aria-labelledby'));

            // get the focusable items in the panel
            $focusable.length = 0;
            $focusable = $nextPanel.find(':focusable');

            if ($focusable.length > 0) {
              // there are focusable items in the panel.
              // Set focus to the first item.
              $focusable.first().focus();

              // Reset the aria-selected state of the tabs
              this.$tabs.attr('aria-selected', 'false');

              // Set that associated tab's aria-selected state to true
              $nextTab.attr('aria-selected', 'true');

              e.stopPropagation();
              return false;
            }
          }
        }
      }

      break;
    }

    case this.keyCodes.left:
    case this.keyCodes.up: {

      if (!e.ctrlKey) {
        // do not process
        return true;
      }

      // get the jQuery object of the tab
      var $tab = $('#' + $panel.attr('aria-labelledby'));

      // Move focus to the tab
      $tab.focus();

      e.stopPropagation();
      return false;
    }
    case this.keyCodes.pageup: {

      var $newTab;

      if (!e.ctrlKey) {
        // do not process
        return true;
      }

      // get the jQuery object of the tab
      this.$tab = this.$tabs.filter('[aria-selected="true"]');

      // get the index of the tab in the tab list
      this.curNdx = this.$tabs.index(this.$tab);

      if (this.curNdx === 0) {
        // this is the first tab, set focus on the last one
        $newTab = this.$tabs.last();

      }else {
        // set focus on the previous tab
        $newTab = this.$tabs.eq(curNdx - 1);
      }

      // switch to the new tab
      this.switchTabs($tab, $newTab);

      e.stopPropagation();
      e.preventDefault();
      return false;
    }
    case this.keyCodes.pagedown: {

      if (!e.ctrlKey) {
        // do not process
        return true;
      }

      // get the jQuery object of the tab
      this.$tab = $('#' + $panel.attr('aria-labelledby'));

      // get the index of the tab in the tab list
      this.curNdx = this.$tabs.index(this.$tab);

      if (curNdx == this.$tabs.length-1) {
        // this is the last tab, set focus on the first one
        $newTab = this.$tabs.first();
      }
      else {
        // set focus on the next tab
        $newTab = this.$tabs.eq(curNdx + 1);
      }

      // switch to the new tab
      this.switchTabs($tab, $newTab);

      e.stopPropagation();
      e.preventDefault();
      return false;
    }
    }

    return true;
  },


  //
  // Function handlePanelKeyPress() is a member function to process keypress events for a panel
  //
  // @param ($panel obj) $panel is the jquery object of the panel being processed
  //
  // @paran (e obj) e is the associated event object
  //
  // @return (boolean) Returns true if propagating; false if consuming event
  //
  handlePanelKeyPress : function($panel, e) {

    if (e.altKey) {
      // do nothing
      return true;
    }

    if (e.ctrlKey && (e.keyCode == this.keyCodes.pageup || e.keyCode == this.keyCodes.pagedown)) {
      e.stopPropagation();
      e.preventDefault();
      return false;
    }

    switch (e.keyCode) {
    case this.keyCodes.esc: {
      e.stopPropagation();
      e.preventDefault();
      return false;
    }
    }

    return true;

  },


  //
  // Function handlePanelClick() is a member function to process click events for panels
  //
  // @param ($panel object) $panel is the jQuery object of the panel being processed
  //
  // @param (e object) e is the associated event object
  //
  // @return (boolean) returns true
  //
  handlePanelClick: function () {

    var $tab = $('#' + this.$panel.attr('aria-labelledby'));

    // make clicked panel's tab navigable
    $tab.attr('tabindex', '0').attr('aria-selected', 'true');

    // remove all tabs from the tab order and update their aria-selected attribute
    this.$tabs.not($tab).attr('tabindex', '-1').attr('aria-selected', 'false');

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
    if (($(element)[(nodeName === 'area' ? 'parents' : 'closest')](':hidden').length) ==- true) {
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
    if ((nodeName == 'a' ||  nodeName == 'area') === true) {

      return (element.href.length > 0);
    }

    // this is some other page element that is not normally focusable.
    return false;
  }
});
