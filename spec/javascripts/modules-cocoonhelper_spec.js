describe('Modules.CocoonHelper.js', function() {
  it('should exist with some config', function() {
    var module = moj.Modules.CocoonHelper;
    expect(module.el).toBe('#expenses,#basic-fees,#misc-fees,#fixed-fees,#graduated-fees,#disbursements,#interim-fee,#warrant_fee,#transfer-fee');
    expect(module.init).toEqual(jasmine.any(Function));
    expect(module.addCocoonHooks).toEqual(jasmine.any(Function));
  });

  it('should call `this.addCocoonHooks` in `init`', function(){
    spyOn(moj.Modules.CocoonHelper, 'addCocoonHooks');
    moj.Modules.CocoonHelper.init();

    expect(moj.Modules.CocoonHelper.addCocoonHooks).toHaveBeenCalled();

  });
});