describe('Cookies', () => {
  beforeEach(() => {
    cy.visit('/')
    cy.getCookie('usage_opt_in').should('have.property', 'value', 'false')
    cy.getCookie('cookies_preference').should('not.exist')
  })

  context('Banner', () => {
    it('shows the correct banners when cookies are accepted', () => {
      cy.get('a').contains('Accept analytics cookies').click()
      cy.get('.govuk-cookie-banner__confirmation').contains('Your cookie settings were saved').should('exist')
      cy.getCookie('usage_opt_in').should('have.property', 'value', 'true')
      cy.getCookie('cookies_preference').should('have.property', 'value', 'true')
      cy.get('a').contains('Hide this message').click()
      cy.get('.govuk-cookie-banner').should('not.exist')
    })

    it('shows the correct banners when cookies are rejected', () => {
      cy.get('a').contains('Reject analytics cookies').click()
      cy.get('.govuk-cookie-banner__confirmation').contains('Your cookie settings were saved').should('exist')
      cy.getCookie('usage_opt_in').should('have.property', 'value', 'false')
      cy.getCookie('cookies_preference').should('have.property', 'value', 'true')
      cy.get('a').contains('Hide this message').click()
      cy.get('.govuk-cookie-banner').should('not.exist')
    })
  })

  context('Page', () => {
    it('does not show banner when accepting cookies in settings', () => {
      cy.get('a').contains('View cookies').click()
      cy.get('#cookies-analytics-true-field').click()
      cy.get('[type=submit]').click()
      cy.get('.govuk-notification-banner--success').contains("You've set your cookie preferences.").should('exist')
      cy.get('.govuk-cookie-banner').should('not.exist')
      cy.getCookie('usage_opt_in').should('have.property', 'value', 'true')
      cy.getCookie('cookies_preference').should('have.property', 'value', 'true')
    })

    it('does not show banner when rejecting cookies in settings', () => {
      cy.get('a').contains('View cookies').click()
      cy.get('#cookies-analytics-false-field').click()
      cy.get('[type=submit]').click()
      cy.get('.govuk-notification-banner--success').contains("You've set your cookie preferences.").should('exist')
      cy.get('.govuk-cookie-banner').should('not.exist')
      cy.getCookie('usage_opt_in').should('have.property', 'value', 'false')
      cy.getCookie('cookies_preference').should('have.property', 'value', 'true')
    })
  })
})
