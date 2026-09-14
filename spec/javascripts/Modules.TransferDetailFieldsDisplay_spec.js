describe('Modules.TransferDetailFieldsDisplay.js', function () {
  const module = moj.Modules.TransferDetailFieldsDisplay

  beforeEach(function () {
    $('body').append([
      '<div class="js-case-conclusion-effectors">',
      '  <div class="js-litigator-type"><input type="radio" value="new" checked></div>',
      '  <div class="js-elected-case"><input type="radio" value="false" checked></div>',
      '  <select class="js-transfer-stage-id"><option value="20" selected>Before trial transfer</option></select>',
      '</div>'
    ].join(''))
    spyOn($, 'ajax')
  })

  afterEach(function () {
    $('.js-case-conclusion-effectors').remove()
  })

  it('loads case-conclusion JavaScript over same-origin XHR', function () {
    module.init()

    expect($.ajax).toHaveBeenCalledWith(jasmine.objectContaining({
      url: '/case_conclusions',
      data: 'litigator_type=new&elected_case=false&transfer_stage_id=20',
      dataType: 'script',
      headers: { 'X-Requested-With': 'XMLHttpRequest' }
    }))
  })
})
