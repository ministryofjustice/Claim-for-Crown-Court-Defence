moj.Modules.DeterminationCalculator = {
  el                   : '#determinations',
  $determinationsTable : {},
  $totalExclVat        : {},
  $totalInclVat        : {},
  $totalVat            : {},
  ajaxVat              : false,
  vatUrl               : '',
  vatDate              : '',

  cacheEls: function(){
    this.$determinationsTable = $(this.el);
    this.$totalExclVat = $('.js-total-exc-vat-determination', this.$determinationsTable);
    this.$totalVat = $('.js-vat-determination', this.$determinationsTable);
    this.$LgfsVat = $('.js-lgfs-vat-determination', this.$determinationsTable);
    this.$totalInclVat = $('.js-total-determination', this.$determinationsTable);
    this.scheme = this.$determinationsTable.data('scheme');
    this.ajaxVat = this.$determinationsTable.data('applyVat');
    this.vatUrl = this.$determinationsTable.data('vatUrl');
    this.vatDate = this.$determinationsTable.data('submittedDate');
  },

  init : function() {

    this.cacheEls();

    this.addChangeEvent();

    var self = this;

    this.$determinationsTable
      //Find all the rows
      .find('tr')
      //that have input fields
      .has(':text')
      .first()
      //Work out the total for each row
      .each(function(){
        //cache the current row
        var $tr = $(this);
        var firstInput = $tr.find(':text').get(0);

        //Calculate the rows total.
        self.calculateTotalRows(firstInput);
      });
  },

  calculateAmount: function (fee, expenses, disbursements) {
    var f = fee || 0,
        e = expenses || 0,
        d = disbursements || 0;

    f = f < 0 ? 0 : f;
    e = e < 0 ? 0 : e;
    d = d < 0 ? 0 : d;

    var t = (f + e + d).toFixed(2);
    t = t < 0 ? 0 : t;
    return t;
  },

  addChangeEvent: function() {
    var self = this;
    $(this.el).on('change', ':text', function() {
      self.calculateTotalRows(this);
    });
  },

  calculateTotalRows : function(element){
    //Cache the element that triggered the event
    var $element = $(element);
    var $table = $element.closest('table');
    var $fees = $table.find('.js-fees');
    var $expenses = $table.find('.js-expenses');
    var $disbursements = $table.find('.js-disbursements');

    var fees = $fees.exists() ? parseFloat($fees.val().replace(/,/g, '')) : 0;
    var expenses = $expenses.exists() ? parseFloat($expenses.val().replace(/,/g, '')) : 0;
    var disbursements = $disbursements.exists() ? parseFloat($disbursements.val().replace(/,/g, '')) : 0;

    var total = this.calculateAmount(fees, expenses, disbursements);

    this.applyVAT(total);
  },

  getVAT: function(netAmount) {
    return $.ajax({
      url: this.vatUrl,
      data: {
        scheme: this.scheme,
        lgfs_vat_amount: this.$LgfsVat.val(),
        date: this.vatDate,
        apply_vat: this.ajaxVat,
        net_amount: netAmount
      }
    });
  },

  applyVAT : function(netAmount){

    var self = this;

    //If Total is not a valid number
    if(isNaN(netAmount)){
      self.$totalExclVat.text('£0.00');
      self.$totalVat.text('£0.00');
      self.$totalExclVat.text('£0.00');

    }else{
      $.when(this.getVAT(netAmount))
      .then(function( data){
        self.$totalExclVat.text(data.net_amount);
        self.$totalVat.text(data.vat_amount);
        self.$totalInclVat.text(data.total_inc_vat);
      });
    }
  }
};
