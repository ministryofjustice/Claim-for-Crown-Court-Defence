describe('Forgot password', () => {
  beforeEach(() => {
    cy.visit('/users/password/new')
  })

  it('accepts request to send instructions to reset password', () => {
    cy.customCheckAlly()

    cy.get('form').within(() => {
      cy.get('#user-email-field').type('email@example.com')
      cy.get('[type=submit]').click()
    })

    cy.get('.notice-summary-heading')
      .should('contain', 'you will receive a password recovery link at your email address')
    cy.customCheckAlly()
  })

  it('accepts request to resend instructions to reset password', () => {
    cy.contains("Didn't receive unlock instructions?").click()
    cy.title().should('contain', 'Resend unlock instructions')
    cy.customCheckAlly()

    cy.get('form').within(() => {
      cy.get('#user-email-field').type('email@example.com')
      cy.get('[type=submit]').click()
    })

    cy.get('#notice-summary-heading')
      .should('contain', 'you will receive an email with instructions for how to unlock it in a few minutes')
    cy.customCheckAlly()
  })
})
