describe("Modules.OffenceCtrl.js", function() {
  var module = moj.Modules.OffenceCtrl;

  var view = function(data) {

    data = $.extend({}, data, {
      value: '',
      fee_scheme: 'AGFS 10'
    });
    return $([
      '<div id="offence-view">',
      '<div id="cc-offence">',
      '  <select class="fx-autocomplete" id="claim_offence_category_description">',
      '    <option value=""></option>',
      '    <option value="Abandonment of children under two">Abandonment of children under two</option>',
      '    <option value="Abduction of defective from parent">Abduction of defective from parent</option>',
      '    <option value="Abduction of unmarried girl under 16 from parent">Abduction of unmarried girl under 16 from parent</option>',
      '  </select>',
      '</div>',
      '<div class="offence-class-select"></div>',
      '<input type="hidden" value="" id="claim_offence_id">',
      '</div>'
    ].join(''));
  };


  beforeEach(function() {
    $('body').append(view());
  });

  afterEach(function() {
    $('body #offence-view').remove();
  });

  describe('...defaults', function() {
    it('should behave `els` selectors defined', function() {
      expect(module.els.offenceClassSelectWrapper).toEqual('.offence-class-select');
      expect(module.els.offenceClassSelect).toEqual('#offence_class_description');
      expect(module.els.offenceID).toEqual('#claim_offence_id');
      expect(module.els.offenceCategoryDesc).toEqual('#claim_offence_category_description');

    });
  });


  describe('...Methods', function() {
    describe('...init', function() {
      it('should call `this.autocomplete`...', function() {
        spyOn(module, 'autocomplete');

        module.init();
        expect(module.autocomplete).toHaveBeenCalledWith();
      });
      it('should call `this.checkState`...', function() {
        spyOn(module, 'checkState');

        module.init();
        expect(module.checkState).toHaveBeenCalledWith();
      });
      it('should call `this.bindEvents`...', function() {
        spyOn(module, 'bindEvents');

        module.init();
        expect(module.bindEvents).toHaveBeenCalledWith();
      });
    });
    describe('...checkState', function() {
      it('should call `this.attachToOffenceClassSelect`...', function() {
        spyOn(module, 'attachToOffenceClassSelect');

        module.checkState();
        expect(module.attachToOffenceClassSelect).toHaveBeenCalledWith();
      });
    });
  });
});
