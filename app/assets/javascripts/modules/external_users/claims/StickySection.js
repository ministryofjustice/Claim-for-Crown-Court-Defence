moj.Modules.StickySection = {
  el: '.sticky-section',
  $sectionWrapper : {},

  isElementInViewport: function(){
    var rect = this.$sectionWrapper[0].getBoundingClientRect();

    return (
      rect.top >= 0 &&
      rect.left >= 0 &&
      rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) && /*or $(window).height() */
      rect.right <= (window.innerWidth || document.documentElement.clientWidth) /*or $(window).width() */
    );
  },

  init: function() {
    this.$sectionWrapper = $(this.el);
    if (!this.$sectionWrapper.length) {
      return;
    }

    this.toggleFixedPanel();
    $(window).on('scroll', $.proxy(this.toggleFixedPanel, this));
  },

  toggleFixedPanel: function() {
    this.$sectionWrapper
      .find('p')
      .toggleClass('fixed-panel-bar', !$.proxy(this.isElementInViewport, this)());
  }
};
