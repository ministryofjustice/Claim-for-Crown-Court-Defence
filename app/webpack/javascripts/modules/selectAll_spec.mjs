import { SelectAll } from './selectAll.mjs'

describe('SelectAll', () => {
  describe('toggleSelection', () => {
    let selectAllBox = null
    let selectedBox = null
    let unselectedBox = null
    let testArea = null

    beforeEach(() => {
      document.body.classList.add('govuk-frontend-supported')

      testArea = document.createElement('div')
      document.body.appendChild(testArea)

      // <div data-module="govuk-select-all" data-select-all-class="selector-box" data collection-class="pick-me">
      //   <input class="selector-box" type="checkbox" />
      // </div>
      const selectAllDiv = document.createElement('div')
      selectAllDiv.setAttribute('data-module', 'govuk-select-all')
      selectAllDiv.setAttribute('data-select-all-class', 'selector-box')
      selectAllDiv.setAttribute('data-collection-class', 'pick-me')
      selectAllBox = document.createElement('input')
      selectAllBox.type = 'checkbox'
      selectAllBox.classList.add('selector-box')
      selectAllBox.checked = false
      selectAllDiv.appendChild(selectAllBox)
      testArea.appendChild(selectAllDiv)

      // <input class="pick-me" type="checkbox" name="box1" checked=true>
      selectedBox = createCheckbox('pick-me', true, 'box1')
      testArea.appendChild(selectedBox)

      // <input class="pick-me" type="checkbox" name="box2">
      unselectedBox = createCheckbox('pick-me', true, 'box1')
      testArea.appendChild(unselectedBox)

      const selectAll = new SelectAll(selectAllDiv)
      selectAll.init()
    })

    afterEach(() => {
      document.body.classList.remove('govuk-frontend-supported')
      testArea.remove()
    })

    const createCheckbox = (className, checked = false, name = '') => {
      const checkbox = document.createElement('input')
      checkbox.type = 'checkbox'
      checkbox.classList.add(className)
      checkbox.name = name
      checkbox.checked = checked
      return checkbox
    }

    const toggleSelectAll = () => {
      const event = new Event('change')
      selectAllBox.checked = !selectAllBox.checked
      selectAllBox.dispatchEvent(event)
    }

    it('should mark all checkboxes as checked', () => {
      toggleSelectAll()

      expect(selectedBox.checked).toBeTrue()
      expect(unselectedBox.checked).toBeTrue()
    })

    it('should mark all checkboxes as unchecked', () => {
      toggleSelectAll()
      toggleSelectAll()

      expect(selectedBox.checked).toBeFalse()
      expect(unselectedBox.checked).toBeFalse()
    })

    it('should select newly created boxes', () => {
      const newBox = createCheckbox('pick-me', false, 'new-box')
      document.body.appendChild(newBox)

      toggleSelectAll()

      expect(newBox.checked).toBeTrue()
    })
  })
})
