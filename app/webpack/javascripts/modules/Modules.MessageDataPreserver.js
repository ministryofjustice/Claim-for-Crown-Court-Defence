moj.Modules.MessageDataPreserver = {
  storageKeyPrefix: 'cccd_message_draft_',

  init: function () {
    const self = this
    const path = window.location.pathname
    const match = path.match(/\/case_workers\/claims\/(\d+)/)

    if (!match) return

    self.claimId = match[1]
    self.storageKey = self.storageKeyPrefix + self.claimId

    self.restoreMessageDraft()
    self.bindEvents()
  },

  restoreMessageDraft: function () {
    const self = this
    const saved = sessionStorage.getItem(self.storageKey)
    if (!saved) return

    const field = document.getElementById('message-body-field')
    if (field && !field.value.trim()) {
      field.value = saved
    }
    sessionStorage.removeItem(self.storageKey)
  },

  bindEvents: function () {
    const self = this
    const $form = $('.fx-assesment-hook').closest('form')

    if ($form.length) {
      $form.on('submit', function () {
        self.saveDraft()
      })
    }
  },

  saveDraft: function () {
    const field = document.getElementById('message-body-field')
    if (!field) return
    const messageText = field.value.trim()
    if (messageText) {
      sessionStorage.setItem(this.storageKey, messageText)
    }
  },

  clearDraft: function () {
    if (this.storageKey) {
      sessionStorage.removeItem(this.storageKey)
    }
  }
}
