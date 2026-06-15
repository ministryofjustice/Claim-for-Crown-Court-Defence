describe('Modules.MessageDataPreserver', function () {
  const module = moj.Modules.MessageDataPreserver
  const claimId = '12345'
  const storageKey = 'cccd_message_draft_' + claimId
  const domFixture = $('<div class="main" />')

  const view = [
    '<form action="/case_workers/claims/' + claimId + '" method="post">',
    '  <div class="fx-assesment-hook">',
    '    <div class="js-cw-claim-action">',
    '      <input type="radio" value="authorised" name="claim[state]" />',
    '    </div>',
    '  </div>',
    '  <button type="submit">Update</button>',
    '</form>',
    '<div class="message-controls">',
    '  <form action="/messages" method="post" data-remote="true">',
    '    <textarea id="message-body-field" name="message[body]"></textarea>',
    '    <button type="submit">Send</button>',
    '  </form>',
    '</div>'
  ].join('')

  function setPathname (path) {
    spyOnProperty(window, 'location', 'get').and.returnValue({ pathname: path })
  }

  beforeEach(function () {
    sessionStorage.removeItem(storageKey)
    domFixture.append($(view))
    $('body').append(domFixture)
  })

  afterEach(function () {
    domFixture.empty()
    sessionStorage.removeItem(storageKey)
    module.claimId = null
    module.storageKey = null
  })

  describe('init', function () {
    it('should not activate on non-claim pages', function () {
      setPathname('/case_workers/claims')
      module.init()
      expect(module.claimId).toBeNull()
    })

    it('should extract the claim ID from the URL', function () {
      setPathname('/case_workers/claims/' + claimId)
      module.init()
      expect(module.claimId).toEqual(claimId)
    })

    it('should set the storage key based on claim ID', function () {
      setPathname('/case_workers/claims/' + claimId)
      module.init()
      expect(module.storageKey).toEqual(storageKey)
    })
  })

  describe('restoreMessageDraft', function () {
    beforeEach(function () {
      module.storageKey = storageKey
    })

    it('should restore saved text into the message field', function () {
      sessionStorage.setItem(storageKey, 'Draft message text')
      module.restoreMessageDraft()

      const field = document.getElementById('message-body-field')
      expect(field.value).toEqual('Draft message text')
    })

    it('should remove the stored draft after restoring', function () {
      sessionStorage.setItem(storageKey, 'Draft message text')
      module.restoreMessageDraft()

      expect(sessionStorage.getItem(storageKey)).toBeNull()
    })

    it('should not overwrite existing text in the message field', function () {
      const field = document.getElementById('message-body-field')
      field.value = 'Existing text'

      sessionStorage.setItem(storageKey, 'Draft message text')
      module.restoreMessageDraft()

      expect(field.value).toEqual('Existing text')
    })

    it('should do nothing when no draft is stored', function () {
      const field = document.getElementById('message-body-field')
      field.value = ''
      module.restoreMessageDraft()

      expect(field.value).toEqual('')
    })
  })

  describe('saveDraft', function () {
    beforeEach(function () {
      module.storageKey = storageKey
    })

    it('should save message text to sessionStorage', function () {
      const field = document.getElementById('message-body-field')
      field.value = 'Important message'

      module.saveDraft()

      expect(sessionStorage.getItem(storageKey)).toEqual('Important message')
    })

    it('should not save empty or whitespace-only text', function () {
      const field = document.getElementById('message-body-field')
      field.value = '   '

      module.saveDraft()

      expect(sessionStorage.getItem(storageKey)).toBeNull()
    })

    it('should trim whitespace before saving', function () {
      const field = document.getElementById('message-body-field')
      field.value = '  Trimmed message  '

      module.saveDraft()

      expect(sessionStorage.getItem(storageKey)).toEqual('Trimmed message')
    })
  })

  describe('clearDraft', function () {
    it('should remove the draft from sessionStorage', function () {
      module.storageKey = storageKey
      sessionStorage.setItem(storageKey, 'Some draft')

      module.clearDraft()

      expect(sessionStorage.getItem(storageKey)).toBeNull()
    })
  })

  describe('bindEvents', function () {
    beforeEach(function () {
      module.storageKey = storageKey
    })

    it('should save draft when assessment form is submitted', function () {
      spyOn(module, 'saveDraft')
      module.bindEvents()

      const $form = $('.fx-assesment-hook').closest('form')
      $form.trigger('submit')

      expect(module.saveDraft).toHaveBeenCalled()
    })
  })
})
