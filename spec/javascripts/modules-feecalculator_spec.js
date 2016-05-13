describe('Modules.FeeCalculator.js', function() {
  it('should exist with some config', function() {
    var module = moj.Modules.FeeCalculator;
    expect(module.el).toBe('#expenses, #basic-fees, #misc-fees, #fixed-fees, #graduated-fees');
    expect(module.init).toEqual(jasmine.any(Function));
    expect(module.calculateAmount).toEqual(jasmine.any(Function));
    expect(module.addCocoonHooks).toEqual(jasmine.any(Function));
    expect(module.addChangeEvent).toEqual(jasmine.any(Function));
    expect(module.calculateRow).toEqual(jasmine.any(Function));
    expect(module.totalFee).toEqual(jasmine.any(Function));
  });
  describe('Methods', function() {

    describe('...calculateAmount', function(){
      var expectedValue;
      it('should default `rate` to zero', function(){
        expectedValue = moj.Modules.FeeCalculator.calculateAmount(undefined, 2);
        expect(expectedValue).toEqual('0.00');
      });

      it('should handle NaN by setting `quantity` to 1', function(){
        expectedValue = moj.Modules.FeeCalculator.calculateAmount(784.23, 'david');
        expect(expectedValue).toEqual('784.23');
      });
      it('should multiply the rate and quantity', function(){
        expectedValue = moj.Modules.FeeCalculator.calculateAmount(93.83, 2);
        expect(expectedValue).toEqual('187.66');

        expectedValue = moj.Modules.FeeCalculator.calculateAmount(9, 8.5);
        expect(expectedValue).toEqual('76.50');
      });


    });
  });
});