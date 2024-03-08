import { initAll } from 'govuk-frontend'
import { Determination } from '../javascripts/modules/determination.mjs'

// fonts & images
require.context('govuk-frontend/dist/govuk/assets', true)

const determinations = document.querySelectorAll('[data-module="govuk-determination"]')
determinations.forEach((determination) => {
  new Determination(determination).init()
})

initAll()
