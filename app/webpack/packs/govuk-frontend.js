import '../stylesheets/govuk-frontend.scss'

import { Determination } from '../javascripts/modules/determination.mjs'

// fonts & images
require.context('govuk-frontend/govuk/assets', true)

const determinations = document.querySelectorAll('[data-module="govuk-determination"]')
determinations.forEach((determination) => {
  new Determination(determination).init()
})

require('govuk-frontend').initAll()
