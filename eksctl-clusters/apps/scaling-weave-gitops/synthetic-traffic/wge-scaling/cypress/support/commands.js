Cypress.Commands.add('login', (username, password) => {
    cy.session([username, password], () => {
        cy.visit('/sign_in')
        cy.get('#email').type(username)
        cy.get('#password').type(password)
        cy.get('.MuiButtonBase-root').contains('CONTINUE').click()
        cy.url().should('contain', '/clusters')
    })
})