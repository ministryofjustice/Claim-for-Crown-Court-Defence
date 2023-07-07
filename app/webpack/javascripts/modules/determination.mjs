/**
 * Determination
 *
 * Calculate totals for the assessment summary on case_workers/claims/<claim-id>
 *
 *
 * <div data-module="govuk-determination" data-apply-vat="true" data-vat-url="/vat.json" data-submitted-date="2023-06-27" data-scheme="agfs">
 *   <!-- Calculated values -->
 *   <span class="js-total-exc-vat-determination">...</span>
 *   <span class="js-vat-determination"...</span>
 *   <span class="js-total-determination">...</span>
 *
 *   <!-- Fields used for the calculation -->
 *   <input id="claim_assessment_attributes_fees" />
 *   <input id="claim_assessment_attributes_expenses" />
 *   <input id="claim_assessment_attributes_disbursements" />
 *
 *   <!-- Field for LGFS claims -->
 *   <input class="js-lgfs-vat-determination"id=" claim_assessment_attributes_vat_amount">£0.00</span>
 * </div>
 */

export class Determination {
  /**
   * @param {Element} $module - HTML element to use for component
   */
  constructor ($module) {
    if (($module instanceof window.HTMLElement) && document.body.classList.contains('govuk-frontend-supported')) {
      this.$module = $module
    }
  }

  /**
   * Initialise component
   */
  init () {
    if (!this.$module) { return }

    const $module = this.$module

    this.$totalExclVat = $module.querySelector('.js-total-exc-vat-determination')
    this.$totalVat = $module.querySelector('.js-vat-determination')
    this.$LgfsVat = $module.querySelector('.js-lgfs-vat-determination')
    this.$totalInclVat = $module.querySelector('.js-total-determination')
    this.scheme = $module.dataset.scheme
    // Should this be this.applyVat?
    this.ajaxVat = $module.dataset.applyVat
    this.vatUrl = $module.dataset.vatUrl
    this.vatDate = $module.dataset.submittedDate

    const fieldIds = [
      'fees',
      'expenses',
      'disbursements',
      'vat_amount'
    ]

    this.fields = fieldIds.map(id => document.querySelector(`#claim_assessment_attributes_${id}`)).filter(field => field)
    this.fields.forEach(element => element.addEventListener('change', () => {
      this.calculateTotalRows()
      return true
    }))
  }

  calculateTotalRows () {
    const total = this.fields.reduce((n, field) => n + (parseFloat(field?.value) || 0.0), 0).toFixed(2)
    return this.applyVat(total).then(data => {
      this.$totalExclVat.innerHTML = data.net_amount
      if (this.$totalVat) { this.$totalVat.innerHTML = data.vat_amount }
      this.$totalInclVat.innerHTML = data.total_inc_vat
    })
  }

  async applyVat (netAmount) {
    const params = new URLSearchParams({
      scheme: this.scheme,
      lgfs_vat_amount: this.$LgfsVat?.value,
      date: this.vatDate,
      apply_vat: this.ajaxVat,
      net_amount: netAmount
    })
    const response = await fetch(this.vatUrl + '?' + params.toString())

    return await response.json()
  }
}
