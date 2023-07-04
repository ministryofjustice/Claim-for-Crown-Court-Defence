moj.Modules.UnclaimedFees = {
  init: function () {
    this.checkListWrapper = document.getElementById('mod-unclaimed-fees')
    if (this.checkListWrapper) {
      this.button = document.getElementById('add-unclaimed-fees')
      const form = this.button.closest("form")
      this.url = form.getAttribute("action")
      this.token = Array.from(form.getElementsByTagName("input")).filter(i => i.getAttribute("name") === "authenticity_token")[0].value
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

  submit: async function (event) {
    event.preventDefault()

    const feesToAdd = this.checkBoxes.filter(box => box.checked)

    const response = await fetch(this.url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        authenticity_token: this.token,
        fees: feesToAdd.map(fee => fee.value)
      })
    }).then(response => {
      if (response.ok) {
        feesToAdd.forEach(box => box.disabled = true)
        this.setSubmitButton()
      } else {
        console.log('There was a problem')
      }
    })
  }
}