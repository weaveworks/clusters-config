describe('meilisearch - synthetic traffic', () => {

    it('should see applications', () => {
        cy.visit('/', {
            headers: {
                'accept': 'application/json, text/plain, */*',
                'user-agent': 'axios/0.27.2'
            }
        });
    })
})