const WAITING_TIME = Cypress.env('waitingTime')

describe(`Test search`, () => {
    it("gets a list of movies", () => {
        cy.request("GET", "/indexes/movies/search").then((response) => {
            expect(response.status).to.eq(200)
            expect(response.body.hits).to.have.lengthOf(20)
        })
    })
})
