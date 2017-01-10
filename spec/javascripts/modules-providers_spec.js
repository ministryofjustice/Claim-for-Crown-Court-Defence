describe('Modules.Provider.js', function() {
  var module = moj.Modules.Providers;
  it('should subscribe to 3 events', function() {
    spyOn($, 'subscribe');

    module.init();
    expect($.subscribe.calls.all().length).toEqual(3);
    expect($.subscribe.calls.all()[0].args[0]).toMatch('/provider/type/');
    expect($.subscribe.calls.all()[1].args[0]).toMatch('/scheme/type/agfs/');
    expect($.subscribe.calls.all()[2].args[0]).toMatch('/scheme/type/agfs/proxy/');

  });


  describe('/provider/type/', function() {
    it('should publish `/scheme/type/agfs/`', function() {

      spyOn($, 'publish').and.callThrough();

      $.publish('/provider/type/', {
        some: 'thing'
      });

      expect($.publish.calls.all()[1].args).toEqual(['/scheme/type/agfs/', Object({
        some: 'thing'
      })]);
    });
  });

  describe('/scheme/type/agfs/', function() {
    it('should publish `/scheme/type/agfs/proxy/`', function() {

      spyOn($, 'publish').and.callThrough();

      $.publish('/scheme/type/agfs/');

      expect($.publish.calls.all()[1].args).toEqual(['/scheme/type/agfs/proxy/', Object({
        provider: 'firm',
        agfs: false
      })]);
    });
  });

  describe('/scheme/type/agfs/proxy/', function() {
    it('should publish `/scheme/type/agfs/custom/` with the correct values', function() {

      spyOn($, 'publish').and.callThrough();

      $.publish('/scheme/type/agfs/proxy/', {
        provider: 'something',
        agfs: 'someting'
      });

      expect($.publish.calls.all()[1].args).toEqual(['/scheme/type/agfs/custom/', Object({
        eventValue: 'hide-agfs-supplier'
      })]);


      $.publish('/scheme/type/agfs/proxy/', {
        provider: 'firm',
        agfs: true
      });

      expect($.publish.calls.all()[2].args).toEqual(['/scheme/type/agfs/proxy/', Object({
        provider: 'firm',
        agfs: true
      })]);

      $.publish('/scheme/type/agfs/proxy/', {
        provider: 'chamber',
        agfs: true
      });

      expect($.publish.calls.all()[4].args).toEqual(['/scheme/type/agfs/proxy/', Object({
        provider: 'chamber',
        agfs: true
      })]);

    });
  });


});