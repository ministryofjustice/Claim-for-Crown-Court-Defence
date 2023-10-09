/**
 * SelectAll
 *
 * A checkbox that is used to automatically select and deselect a collection of other checkboxes.
 *
 *   * data-select-all-class defines the class to identify the 'select all' checkbox
 *   * data-collection-class defines the class to identify the checkboxes in the collection
 *
 * <div data-module="govuk-select-all" data-select-all-class="select-all" data-collection-class="select-all-box" >
 *   <input class="select-all" type="checkbox" />
 * </div>
 *
 * <input class="select-all-box" type="checkbox" id="option_1" />
 * <input class="select-all-box" type="checkbox" id="option_2" />
 * <input class="select-all-box" type="checkbox" id="option_3" />
 * <input class="select-all-box" type="checkbox" id="option_4" />
 * <input type="checkbox" id="option_5 /> <!-- not part of the collection" -->
 */
export class SelectAll {
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
    // Check that required elements are present
    if (!this.$module) { return }

    const selector = this.$module.dataset.selectAllClass
    this.collection = this.$module.dataset.collectionClass

    this.selectAllBox = this.$module.querySelector(`.${selector}`)
    this.selectAllBox.addEventListener('change', () => this.toggleSelection())
  }

  toggleSelection = () => {
    const checkBoxes = document.querySelectorAll(`.${this.collection}`)
    checkBoxes.forEach((box) => { box.checked = this.selectAllBox.checked })
  }
}
