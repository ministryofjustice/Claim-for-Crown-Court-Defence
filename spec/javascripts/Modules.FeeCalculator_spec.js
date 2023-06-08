describe('Modules.FeeCalculator.js', function () {
  const module = moj.Modules.FeeCalculator.UnitPrice

  it('...should exist', function () {
    expect(moj.Modules.FeeCalculator).toBeDefined()
  })

  describe('...methods', function () {
    describe('...init', function () {
      it('...should call `this.bindEvents`', function () {
        spyOn(module, 'bindEvents')
        module.init()
        expect(module.bindEvents).toHaveBeenCalled()
      })
    })
    describe('...bindEvents', function () {
      it('...should call `this.advocateTypeChange`', function () {
        spyOn(module, 'advocateTypeChange')
        module.bindEvents()
        expect(module.advocateTypeChange).toHaveBeenCalled()
      })
      it('...should call `this.miscFeeTypeChange`', function () {
        spyOn(module, 'miscFeeTypeChange')
        module.bindEvents()
        expect(module.miscFeeTypeChange).toHaveBeenCalled()
      })
      it('...should call `this.fixedFeeTypeChange`', function () {
        spyOn(module, 'fixedFeeTypeChange')
        module.bindEvents()
        expect(module.fixedFeeTypeChange).toHaveBeenCalled()
      })
      it('...should call `this.feeRateChange`', function () {
        spyOn(module, 'feeRateChange')
        module.bindEvents()
        expect(module.feeRateChange).toHaveBeenCalled()
      })
      it('...should call `this.feeQuantityChange`', function () {
        spyOn(module, 'feeQuantityChange')
        module.bindEvents()
        expect(module.feeQuantityChange).toHaveBeenCalled()
      })
      it('...should call `this.miscFeeFormRefresh`', function () {
        spyOn(module, 'miscFeeFormRefresh')
        module.bindEvents()
        expect(module.miscFeeFormRefresh).toHaveBeenCalled()
      })
      it('...should call `this.pageLoad`', function () {
        spyOn(module, 'pageLoad')
        module.bindEvents()
        expect(module.pageLoad).toHaveBeenCalled()
      })
    })
    describe('...setHintLabel', function () {
      it('...should return the input as default', function () {
        expect(module.setHintLabel()).toEqual('')
      })
      it('...should return the correct `HALFDAY`', function () {
        expect(module.setHintLabel('HALFDAY')).toEqual('Number of half days')
      })
      it('...should return the correct `DEFENDANT`', function () {
        expect(module.setHintLabel('DEFENDANT')).toEqual('Number of additional defendants')
      })
      it('...should return the correct `CASE`', function () {
        expect(module.setHintLabel('CASE')).toEqual('Number of additional cases')
      })
      it('...should return the correct `CASE`', function () {
        expect(module.setHintLabel('AABB')).toEqual('Number of aabbs')
      })
    })
  })
})
