describe('Log in', () => {
  it('logs in successfully', () => {
    cy.app('clean')
    cy.appFactories([
      ['create', 'external_user', 'for_test']
    ])

    cy.visit('/')
    cy.get('#user-email-field').type('person@example.com')
    cy.get('#user-password-field').type('password')
    cy.get('[type=submit]').click()

    cy.get('#notice-summary-heading').should('contain', 'Signed in successfully.')
    cy.title().should('equal', 'View your claims')
  })

  context('when I try to log in with the wrong credentials', () => {
    it('fails authentication', () => {
      cy.visit('/')
      cy.get('#user-email-field').type('wrong_email@example.com')
      cy.get('#user-password-field').type('password')
      cy.get('[type=submit]').click()

      cy.get('#error-summary-heading').should('contain', 'Invalid Email or password.')
      cy.title().should('equal', 'Sign in to claim for Crown court defence')
    })
  })

  context('when I have forgotten the password', () => {
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
})
