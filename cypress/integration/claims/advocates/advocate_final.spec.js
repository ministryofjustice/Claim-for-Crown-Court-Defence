/// <reference types="cypress" />

describe('As an Advocate', () => {
  before(() => {
    // TODO: make a custom command for db seed and teardown
    // TODO: only clear and seed specific db tables
    cy.exec('bundle exec rake db:clear', { env: { RAILS_ENV: 'test' }, timeout: 120000 })
    cy.exec('bundle exec rake db:reload', { env: { RAILS_ENV: 'test' }, timeout: 120000 }).its('code').should('eq', 0)
  })

  beforeEach(() => {
    cy.visit('/')
  })

  it('Log in fails when I enter the incorrect account details', () => {
    cy.get('#user-email-field').type('wrong_email@example.com')
    cy.get('#user-password-field').type('notavalidaccount')
    cy.get('[type=submit]').click()

    cy.get('#error-summary-heading').should('contain', 'Invalid Email or password.')
    cy.title().should('equal', 'Sign in to claim for Crown court defence')
  })

  it('I can successfully log in', () => {
    cy.get('#user-email-field').type('advocate@example.com')
    cy.get('#user-password-field').type('whatever')
    cy.get('[type=submit]').click()

    cy.get('#notice-summary-heading').should('contain', 'Signed in successfully.')
    cy.title().should('equal', 'View your claims')
  })

  context('Final fee', () => {
    it('I can successfully submit a final fee claim', () => {
      cy.get('#user-email-field').type('advocate@example.com')
      cy.get('#user-password-field').type('whatever')
      cy.get('[type=submit]').click()

      cy.title().should('equal', 'View your claims')
      cy.get('.govuk-button--start').click()

      // Claim type
      cy.title().should('equal', 'Claim for advocate fees')
      cy.get('#claim-type-id-agfs-field').click()
      cy.get('[type=submit]').contains('Continue').click()

      // Case details
      cy.title().should('equal', 'Enter case details for advocate final fees claim')
      cy.get('#save_continue').contains('Save and continue').click()
      cy.get('.error-summary-list li').its('length').should('equal', 3)
      cy.get('#case_type').select('Contempt')
      cy.get('#court').type('Bolton')
      cy.get('#case_number').type('T20170101')
      cy.get('#save_continue').contains('Save and continue').click()

      // Defendant details
      cy.title().should('equal', 'Enter defendant details for advocate final fees claim')
      cy.get('#save_continue').contains('Save and continue').click()
      cy.get('.error-summary-list li').its('length').should('equal', 5)
      cy.get('#defendant_1_first_name').type('John')
      cy.get('#defendant_1_last_name').type('Doe')
      cy.get('#claim_defendants_attributes_0_date_of_birth_dd').type('1')
      cy.get('#claim_defendants_attributes_0_date_of_birth_mm').type('1')
      cy.get('#claim_defendants_attributes_0_date_of_birth_yyyy').type('2000')
      cy.get('#claim_defendants_attributes_0_representation_orders_attributes_0_representation_order_date_dd').type('1')
      cy.get('#claim_defendants_attributes_0_representation_orders_attributes_0_representation_order_date_mm').type('1')
      cy.get('#claim_defendants_attributes_0_representation_orders_attributes_0_representation_order_date_yyyy').type('2020')
      cy.get('#defendant_1_representation_order_1_maat_reference').type('4123456')
      cy.get('#save_continue').contains('Save and continue').click()

      // Fixed fees
      cy.title().should('equal', 'Enter fixed fees for advocate final fees claim')
      // cy.get('#save_continue').contains('Save and continue').click()
      // cy.get('.error-summary-list li').its('length').should('equal', 2)
      // cy.get('#claim_advocate_category_junior').click()
      // cy.get('#contempt-input').click()

      // // failing xhr request
      // cy.intercept('POST', '/external_users/claims/38/fees/calculate_price.json"').as('calcPrice')
      // cy.wait('@calcPrice').its('response.statusCode').should('eq', 200)

      // cy.get('#fixed_fee_3_quantity').type('1')
      // cy.get('#save_continue').contains('Save and continue').click()

      // // Miscellaneous fees
      // cy.title().should('equal', 'Enter miscellaneous fees for advocate final fees claim')
      // cy.get('#save_continue').contains('Save and continue').click()

      // // Travel fees
      // cy.title().should('equal', 'Enter travel expenses for advocate final fees claim')
      // cy.get('#save_continue').contains('Save and continue').click()

      // // Supporting evidence
      // cy.title().should('equal', 'Upload supporting evidence for advocate final fees claim')
      // cy.get('#save_continue').contains('Save and continue').click()

      // // Claim summary
      // cy.title().should('equal', 'View claim summary for advocate final fees claim')
      // cy.get('.govuk-button').contains('Save and continue').click()

      // // Certification
      // cy.title().should('equal', 'Certify and submit the advocate final fees claim')
      // cy.get('#certification-certification-type-id-8-field').click()
      // cy.get('.govuk-button').contains('Certify and submit claim').click()

      // // Confirmation
      // cy.title().should('equal', 'Thank you for submitting your claim')
    })
  })
})
