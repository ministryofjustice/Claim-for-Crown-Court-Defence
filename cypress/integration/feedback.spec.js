describe('Feedback', () => {
  beforeEach(() => {
    cy.visit('/feedback/new')
  })

  context('submitting feedback', () => {
    it('checks validation and accepts feedback', () => {
      cy.url().should('include', 'feedback/new')
      cy.title().should('eq', 'Help us improve this service')

      cy.customCheckAlly()

      cy.get('[type=submit]').contains('Send').click()
      cy.get('.govuk-error-summary').should('contain', 'Choose a rating')

      cy.customCheckAlly()

      cy.get('form').within(() => {
        cy.get('[name="feedback[email]"]').type('email@example.com')
        cy.get('#feedback-rating-4-field').click()
        cy.get('[type=submit]').contains('Send').click()
      })
      cy.get('.notice-summary-heading').should('contain', 'Feedback submitted')
      cy.customCheckAlly()
    })
  })

  context('reporting a bug', () => {
    it('checks validation and accepts bug report', () => {
      cy.contains('report a fault here').click()
      cy.url().should('include', 'feedback/new?type=bug_report')
      cy.title().should('eq', 'Bug report')

      cy.customCheckAlly()

      cy.get('[type=submit]').contains('Send').click()
      cy.get('.govuk-error-summary').should('contain', 'Event cannot be empty')
      cy.get('.govuk-error-summary').should('contain', 'Outcome cannot be empty')

      cy.customCheckAlly()

      cy.intercept('POST', '/feedback').as('submitBug')

      cy.get('form').within(() => {
        cy.get('[name="feedback[case_number]"]').type('#1000000')
        cy.get('[name="feedback[event]"]').type('I was submitting a claim')
        cy.get('[name="feedback[outcome]"]').type('I could not submit the claim')
        cy.get('[type=submit]').contains('Send').click()
      })

      // TODO: investigate how to stub Zendesk request
      cy.wait('@submitBug').its('response.statusCode').should('eq', 500)
    })
  })
})
