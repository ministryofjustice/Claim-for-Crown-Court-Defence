import { Determination } from './determination.mjs'

describe('Determination', () => {
  let determination = null
  let fetchSpy = null

  describe('calculateTotalRows', () => {
    const inputRow = (id, klass) => {
      const row = document.createElement('tr')
      const cell = document.createElement('td')
      row.append(cell)
      const input = document.createElement('input')
      input.type = 'text'
      input.value = 0.0
      input.id = id
      if (klass) { input.classList.add(klass) }
      cell.append(input)
      return row
    }

    const attributeRow = (id) => {
      const row = document.createElement('tr')
      const cell = document.createElement('td')
      cell.classList.add(id)
      cell.innerHTML = 0.0
      row.append(cell)
      return row
    }

    describe('AGFS claim', () => {
      beforeEach(() => {
        document.body.classList.add('govuk-frontend-supported')

        const testArea = document.createElement('div')
        testArea.classList.add('test-area')
        document.body.appendChild(testArea)

        const table = document.createElement('table')
        table.id = 'determinations'
        table.setAttribute('data-module', 'govuk-determination')
        table.setAttribute('data-apply-vat', 'true')
        table.setAttribute('data-vat-url', '/vat.json')
        table.setAttribute('data-submitted-date', '2023-07-18')
        table.setAttribute('data-scheme', 'agfs')

        const tableBody = document.createElement('thead')
        tableBody.appendChild(inputRow('claim_assessment_attributes_fees'))
        tableBody.appendChild(inputRow('claim_assessment_attributes_expenses'))
        tableBody.appendChild(attributeRow('js-total-exc-vat-determination'))
        tableBody.appendChild(attributeRow('js-vat-determination'))
        tableBody.appendChild(attributeRow('js-total-determination'))

        table.appendChild(tableBody)
        testArea.appendChild(table)

        console.log(testArea)
        determination = new Determination(table)
        determination.init()

        fetchSpy = spyOn(window, 'fetch').and.resolveTo(
          new Response(
            JSON.stringify({
              net_amount: '£196.50',
              vat_amount: '£39.30',
              total_inc_vat: '£235.80'
            }),
            { status: 200, statusText: 'OK' }
          )
        )
      })

      afterEach(() => {
        document.body.classList.remove('govuk-frontend-supported')
        document.querySelector('.test-area').remove()
      })

      it('makes a request to the API', () => {
        document.querySelector('#claim_assessment_attributes_fees').value = 3.14
        document.querySelector('#claim_assessment_attributes_expenses').value = 2.72

        return determination.calculateTotalRows().then(() => {
          const searchParams = new URLSearchParams()
          searchParams.set('scheme', 'agfs')
          searchParams.set('lgfs_vat_amount', 'undefined')
          searchParams.set('date', '2023-07-18')
          searchParams.set('apply_vat', 'true')
          searchParams.set('net_amount', '5.86')

          expect(fetchSpy).toHaveBeenCalledWith('/vat.json?' + searchParams)
        })
      })

      it('sets the net amount', () => {
        return determination.calculateTotalRows().then(() => {
          const netAmount = document.querySelector('.js-total-exc-vat-determination')

          expect(netAmount.innerHTML).toEqual('£196.50')
        })
      })

      it('sets the vat amount', () => {
        return determination.calculateTotalRows().then(() => {
          const netAmount = document.querySelector('.js-vat-determination')

          expect(netAmount.innerHTML).toEqual('£39.30')
        })
      })

      it('sets the total amount', () => {
        return determination.calculateTotalRows().then(() => {
          const totalAmount = document.querySelector('.js-total-determination')

          expect(totalAmount.innerHTML).toEqual('£235.80')
        })
      })
    })

    describe('LGFS claim', () => {
      beforeEach(() => {
        document.body.classList.add('govuk-frontend-supported')

        const testArea = document.createElement('div')
        testArea.classList.add('test-area')
        document.body.appendChild(testArea)

        const table = document.createElement('table')
        table.id = 'determinations'
        table.setAttribute('data-module', 'govuk-determination')
        table.setAttribute('data-apply-vat', 'true')
        table.setAttribute('data-vat-url', '/vat.json')
        table.setAttribute('data-submitted-date', '2023-07-18')
        table.setAttribute('data-scheme', 'lgfs')

        const tableBody = document.createElement('thead')
        tableBody.appendChild(inputRow('claim_assessment_attributes_fees'))
        tableBody.appendChild(inputRow('claim_assessment_attributes_expenses'))
        tableBody.appendChild(inputRow('claim_assessment_attributes_disbursements'))
        tableBody.appendChild(attributeRow('js-total-exc-vat-determination'))
        tableBody.appendChild(inputRow('claim_assessment_attributes_vat_amount', 'js-lgfs-vat-determination'))
        tableBody.appendChild(attributeRow('js-total-determination'))

        table.appendChild(tableBody)
        testArea.appendChild(table)

        console.log(testArea)
        determination = new Determination(table)
        determination.init()

        fetchSpy = spyOn(window, 'fetch').and.resolveTo(
          new Response(
            JSON.stringify({
              net_amount: '£196.50',
              vat_amount: '£39.30',
              total_inc_vat: '£235.80'
            }),
            { status: 200, statusText: 'OK' }
          )
        )
      })

      afterEach(() => {
        document.body.classList.remove('govuk-frontend-supported')
        document.querySelector('.test-area').remove()
      })

      it('makes a request to the API', () => {
        document.querySelector('#claim_assessment_attributes_fees').value = 3.14
        document.querySelector('#claim_assessment_attributes_vat_amount').value = 1.17
        document.querySelector('#claim_assessment_attributes_expenses').value = 2.72

        return determination.calculateTotalRows().then(() => {
          const searchParams = new URLSearchParams()
          searchParams.set('scheme', 'lgfs')
          searchParams.set('lgfs_vat_amount', '1.17')
          searchParams.set('date', '2023-07-18')
          searchParams.set('apply_vat', 'true')
          searchParams.set('net_amount', '7.03')

          expect(fetchSpy).toHaveBeenCalledWith('/vat.json?' + searchParams)
        })
      })

      it('sets the net amount', () => {
        return determination.calculateTotalRows().then(() => {
          const netAmount = document.querySelector('.js-total-exc-vat-determination')

          expect(netAmount.innerHTML).toEqual('£196.50')
        })
      })

      it('sets the total amount', () => {
        return determination.calculateTotalRows().then(() => {
          const totalAmount = document.querySelector('.js-total-determination')

          expect(totalAmount.innerHTML).toEqual('£235.80')
        })
      })
    })
  })
})
