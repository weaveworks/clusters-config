Cypress.Commands.add('login', (username, password) => {
    cy.session([username, password], () => {
        cy.visit('/sign_in')
        cy.get('#email').type(username)
        cy.get('#password').type(password)
        cy.get('.MuiButtonBase-root').contains('CONTINUE').click()

        cy.url().should('contain', '/clusters')
    })
})

describe('weave gitops - applications - synthetic traffic', () => {

    beforeEach(() => {
        cy.login(Cypress.env('WEGO_USERNAME'), Cypress.env('WEGO_PASSWORD'))
    })

    it('should see applications', () => {
        cy.visit('/applications')
    })
})