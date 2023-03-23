describe('weave gitops - explorer - synthetic traffic', () => {

    beforeEach(() => {
        cy.login(Cypress.env('WEGO_USERNAME'), Cypress.env('WEGO_PASSWORD'))
    })

    it('should see applications', () => {
        cy.visit('/explorer/query')
    })
})