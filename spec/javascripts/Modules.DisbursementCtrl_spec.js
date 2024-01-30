describe('Modules.DisbursementCtrl.js', function () {
  const module = moj.Modules.DisbursementsCtrl

  const view = function () {
    return $([
      '<div id="disbursements-view">',
      '<div id="disbursements">',
      '<input value="disbursements" type="hidden" id="claim_form_step" />',
      ' <br/>',
      '</div>',
      '</div>'
    ].join(''))
  }

  beforeEach(function () {
    $('body').append(view())
  })

  afterEach(function () {
    $('body #disbursements-view').remove()
  })

  describe('...defaults', function () {
    it('should behave `els` selectors defined', function () {
      expect(module.els.fxAutocomplete).toEqual('.fx-autocomplete')
    })
  })

  describe('...Methods', function () {
    describe('...init', function () {
      it('...should call `initAutocomplete`', function () {
        spyOn(module, 'initAutocomplete')
        module.init()
        expect(module.initAutocomplete).toHaveBeenCalledWith()
      })

      it('...should call `bindEvents`', function () {
        spyOn(module, 'bindEvents')
        module.init()
        expect(module.bindEvents).toHaveBeenCalledWith()
      })
    })
    describe('...bindEvents', function () {
      it('...should bind on the `cocoon:after-insert`', function () {
        spyOn(moj.Helpers.Autocomplete, 'new')

        module.init()

        $('#disbursements').trigger('cocoon:after-insert')

        expect(moj.Helpers.Autocomplete.new).toHaveBeenCalled()
      })
    })
  })
})
