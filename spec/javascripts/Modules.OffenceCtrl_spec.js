describe('Modules.OffenceCtrl.js', function () {
  const module = moj.Modules.OffenceCtrl

  const view = function () {
    return $([
      '<div id="offence-view">',
      '<div id="cc-offence">',
      '  <select class="fx-autocomplete" id="js-claim-offence-category-description">',
      '    <option value=""></option>',
      '    <option value="Abandonment of children under two">Abandonment of children under two</option>',
      '    <option value="Abduction of defective from parent">Abduction of defective from parent</option>',
      '    <option value="Abduction of unmarried girl under 16 from parent">Abduction of unmarried girl under 16 from parent</option>',
      '  </select>',
      '</div>',
      '<div class="js-offence-class-select-wrapper"></div>',
      '<input type="hidden" value="" id="claim_offence_id">',
      '</div>'
    ].join(''))
  }

  beforeEach(function () {
    $('body').append(view())
  })

  afterEach(function () {
    $('body #offence-view').remove()
  })

  describe('...defaults', function () {
    it('should behave `els` selectors defined', function () {
      expect(module.els.offenceClassSelectWrapper).toEqual('.js-offence-class-select-wrapper')
      expect(module.els.offenceClassSelect).toEqual('.js-offence-class-select select')
      expect(module.els.offenceID).toEqual('#claim_offence_id')
      expect(module.els.offenceCategoryDesc).toEqual('#js-claim-offence-category-description')
    })
  })

  describe('...Methods', function () {
    describe('...init', function () {
      it('should call `this.autocomplete`...', function () {
        spyOn(module, 'autocomplete')

        module.init()
        expect(module.autocomplete).toHaveBeenCalledWith()
      })
      it('should call `this.checkState`...', function () {
        spyOn(module, 'checkState')

        module.init()
        expect(module.checkState).toHaveBeenCalledWith()
      })
      it('should call `this.bindEvents`...', function () {
        spyOn(module, 'bindEvents')

        module.init()
        expect(module.bindEvents).toHaveBeenCalledWith()
      })
    })
    describe('...checkState', function () {
      it('should call `this.attachToOffenceClassSelect`...', function () {
        spyOn(module, 'attachToOffenceClassSelect')

        module.checkState()
        expect(module.attachToOffenceClassSelect).toHaveBeenCalledWith()
      })
    })
  })
})
