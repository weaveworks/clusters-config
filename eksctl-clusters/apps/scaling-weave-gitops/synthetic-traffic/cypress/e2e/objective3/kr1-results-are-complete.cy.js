describe('objective3: results are complete and consistent', () => {
    beforeEach(() => {
        cy.login(Cypress.env('WEGO_USERNAME'), Cypress.env('WEGO_PASSWORD'))
    })
    it('should see consistent result on helm releases', () => {
        let expectedNumItems = 0
        let currentNumItems = 0
        //Given a set of resources in management cluster
        cy.request({
            method: 'GET',
            url: Cypress.env('LEAF_URL') + "/apis/helm.toolkit.fluxcd.io/v2beta1/helmreleases?limit=500",
            failOnStatusCode: false,
            'auth': {
                'bearer': Cypress.env('LEAF_TOKEN')
            },
        }).as('details')
        cy.get('@details').its('status').should('eq', 200)
        cy.get('@details').then((response) => {
            let body = response.body
            expectedNumItems = body.items.length
            cy.log("found items:" + expectedNumItems)
        })

        const checkAndReload = (offset, limit) => {
            cy.request({
                method: 'POST',
                url: "/v1/query",
                failOnStatusCode: true,
                'body': {
                    "query": [{"key": "kind", "value": "HelmRelease", "operand": "equal"}, {
                        "key": "cluster",
                        "value": "flux-system/leaf-cluster-1",
                        "operand": "equal"
                    }], "limit": limit, "offset": offset
                }
            }).as('explorer')
            //then i have the complete data set
            cy.get('@explorer').then((response) => {
                let objects = response.body.objects
                cy.log(objects)
                cy.log("found items:" + currentNumItems)

                if (objects.length === 0) {
                    expect(currentNumItems).to.eq(expectedNumItems)
                    return
                }
                currentNumItems += objects.length
                checkAndReload(offset + limit, limit)
            })
        }
        checkAndReload(0, 25)
    })
    it('should see consistent result on kustomization', () => {
        let expectedNumItems = 0
        let currentNumItems = 0
        //Given a set of resources in management cluster
        cy.request({
            method: 'GET',
            url: Cypress.env('LEAF_URL') + "/apis/kustomize.toolkit.fluxcd.io/v1beta2/kustomizations?limit=500",
            failOnStatusCode: false,
            'auth': {
                'bearer': Cypress.env('LEAF_TOKEN')
            },
        }).as('details')
        cy.get('@details').its('status').should('eq', 200)
        cy.get('@details').then((response) => {
            let body = response.body
            expectedNumItems = body.items.length
            cy.log("found items:" + expectedNumItems)
        })

        const checkAndReload = (offset, limit) => {
            cy.request({
                method: 'POST',
                url: "/v1/query",
                failOnStatusCode: true,
                'body': {
                    "query": [{"key": "kind", "value": "Kustomization", "operand": "equal"}, {
                        "key": "cluster",
                        "value": "flux-system/leaf-cluster-1",
                        "operand": "equal"
                    }], "limit": limit, "offset": offset
                }
            }).as('explorer')
            //then i have the complete data set
            cy.get('@explorer').then((response) => {
                let objects = response.body.objects
                cy.log(objects)
                cy.log("found items:" + currentNumItems)

                if (objects.length === 0) {
                    expect(currentNumItems).to.eq(expectedNumItems)
                    return
                }
                currentNumItems += objects.length
                checkAndReload(offset + limit, limit)
            })
        }
        checkAndReload(0, 25)
    })
})