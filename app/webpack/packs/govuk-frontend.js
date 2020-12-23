import '../stylesheets/govuk-frontend.scss'

// fonts & images
require.context('govuk-frontend/govuk/assets', true)

require('govuk-frontend').initAll()
