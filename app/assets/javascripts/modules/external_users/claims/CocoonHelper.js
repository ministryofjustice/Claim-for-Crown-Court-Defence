moj.Modules.CocoonHelper = {
  el: [
    '#basic-fees',
    '#misc-fees',
    '#fixed-fees',
    '#graduated-fees',
    '#disbursements',
    '#interim-fee',
    '#warrant_fee',
    '#transfer-fee'].join(','),

  init: function() {
    this.addCocoonHooks();
  },

  addCocoonHooks: function() {
    var self = this;
    var $elem = $(this.el);

    $elem.on('cocoon:after-insert', function(e) {
      var $el = $(e.target);
      $el.siblings('.no-dates').hide();

      if($el.find('.gov_uk_date').length >= 2){
        $el.next().hide();
      }



    });

    $elem.on('cocoon:after-remove', function(e) {
      var $el = $(e.target);
      if ($el.find('.fee-dates').length === 0) {
        $el.siblings('.no-dates').show();
      }

      if($el.find('.gov_uk_date').length < 2){
        $el.next().show();
      }

      $el.trigger('recalculate');
    });
  }
};
