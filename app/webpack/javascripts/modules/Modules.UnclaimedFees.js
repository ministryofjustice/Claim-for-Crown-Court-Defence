moj.Modules.UnclaimedFees = {
  init: function () {
    this.checkListWrapper = document.getElementById('mod-unclaimed-fees')
    if (this.checkListWrapper) {
      this.button = document.getElementById('add-unclaimed-fees')
      this.checkBoxes = Array.from(this.checkListWrapper.getElementsByClassName('govuk-checkboxes__input'))
      this.checkBoxes.forEach(box => box.onchange = () => this.setSubmitButton())
      this.setSubmitButton()
      this.button.addEventListener('click', (event) => this.submit(event))
    }
  },

  setSubmitButton: function () {
    if (!this.checkListWrapper) { return }

    this.button.disabled = !this.checkBoxes.reduce((selected, box) => selected || (box.checked && !box.disabled), false)
  },

  submit: function (event) {
    event.preventDefault()

    const feesToAdd = this.checkBoxes.filter(box => box.checked)

    feesToAdd.forEach(box => box.disabled = true)
    this.setSubmitButton()
  }
}