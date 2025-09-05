/*
 * TODO: [js-chamber-advocates-only was removed here](https://github.com/ministryofjustice/Claim-for-Crown-Court-Defence/blame/4493dfb63782ad5df696a4cca65e1b57dcdaaa65/app/views/external_users/admin/external_users/_form.html.haml#L47)
 * I do not believe this module is require any longer, however I also bellieve
 * that current functionality is not performing the conditional diaply of the supplier numer
 * field (but is for "VAT registered" radio options)
 *
 * see [ticket CFP-114](https://dsdmoj.atlassian.net/browse/CFP-114)
*/
moj.Modules.AddEditAdvocate = {
  el: 'js-advocate-roles',
  $userRole: {},
  chamberAdvocates: 'js-chamber-advocates-only',
  $chamberAdvocates: {},
  advocateCheckbox: 'external_user_roles_advocate',
  $advocateCheckbox: {},

  init: function () {
    const self = this
    self.cacheElems()

    if (self.$chamberAdvocates.length > 0) {
      // Check the current state on page load
      self.showHide()

      // Add event listener
      self.$advocateCheckbox.on('change', function () {
        self.showHide()
      })
    }
  },

  cacheElems: function () {
    this.$userRole = $('.' + this.el)
    this.$chamberAdvocates = $('.' + this.chamberAdvocates)
    this.$advocateCheckbox = $('#' + this.advocateCheckbox)
  },

  showHide: function () {
    // Show supplier number and vat registered if the user is an advocate
    if (this.$advocateCheckbox.is(':checked')) {
      this.$chamberAdvocates.show()
    } else {
      this.$chamberAdvocates.hide()
    }
  }
}
