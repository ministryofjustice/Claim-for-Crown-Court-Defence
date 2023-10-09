import '../stylesheets/govuk-frontend.scss'

import { Determination } from '../javascripts/modules/determination.mjs'
import { SelectAll } from '../javascripts/modules/selectAll.mjs'

// fonts & images
require.context('govuk-frontend/govuk/assets', true)

const determinations = document.querySelectorAll('[data-module="govuk-determination"]')
determinations.forEach((determination) => {
  new Determination(determination).init()
})

const selectAlls = document.querySelectorAll('[data-module="govuk-select-all"]')
selectAlls.forEach((selectAll) => {
  new SelectAll(selectAll).init()
})

require('govuk-frontend').initAll()
