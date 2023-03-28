const uuid = () => Cypress._.random(0, 1e6)
const id = uuid()
const helmReleaseName = `podinfo-st-${id}`

describe('objective4: information is realtime for new and updated data', () => {
    beforeEach(() => {
        let helmRelease = {
            "apiVersion": "helm.toolkit.fluxcd.io/v2beta1",
            "kind": "HelmRelease",
            "metadata": {"labels": {"synthetic": "true"}, "name": helmReleaseName, "namespace": "scaling-objective4"},
            "spec": {
                "chart": {
                    "spec": {
                        "chart": "podinfo",
                        "interval": "1m",
                        "reconcileStrategy": "ChartVersion",
                        "sourceRef": {"kind": "HelmRepository", "name": "podinfo"},
                        "version": "6.0.0"
                    }
                }, "interval": "1m"
            }
        }
        //When created a resource
        cy.request({
            method: 'POST',
            url: Cypress.env('LEAF_URL') + "/apis/helm.toolkit.fluxcd.io/v2beta1/namespaces/scaling-objective4/helmreleases?fieldManager=kubectl-client-side-apply&fieldValidation=Strict",
            failOnStatusCode: false,
            'auth': {
                'bearer': Cypress.env('LEAF_TOKEN')
            },
            failOnStatusCode: true,
            'body': helmRelease
        }).as('setup')
        cy.get('@setup').its('status').should('eq', 201)
        cy.login(Cypress.env('WEGO_USERNAME'), Cypress.env('WEGO_PASSWORD'))

    })

    afterEach(() => {
        //clean up resource
        cy.request({
            method: 'DELETE',
            url: Cypress.env('LEAF_URL') + "/apis/helm.toolkit.fluxcd.io/v2beta1/namespaces/scaling-objective4/helmreleases/" + helmReleaseName,
            failOnStatusCode: false,
            'auth': {
                'bearer': Cypress.env('LEAF_TOKEN')
            },
            failOnStatusCode: true,
        }).as('cleanup')
        cy.get('@cleanup').its('status').should('eq', 200)

    })
    it('should see new applications', () => {
        let maxTimes = 5
        let times = 0
        const findCreatedHelmRelease = () => {
            cy.request({
                method: 'POST',
                url: "/v1/query",
                failOnStatusCode: true,
                'body': {
                    "query": [{"key": "kind", "value": "HelmRelease", "operand": "equal"}, {
                        "key": "name",
                        "value": helmReleaseName,
                        "operand": "equal"
                    }], "limit": "25", "offset": "0"
                }
            }).as('explorer')
            //then i have the complete data set
            cy.get('@explorer').then((response) => {
                let objects = response.body.objects
                if (objects.length === 1) {
                    cy.log("found helm release")
                    return
                }
                if (times > maxTimes) {
                    throw new Error("could not find: timeout reached")
                }
                cy.wait(1000);
                times++
                findCreatedHelmRelease()
            })
        }
        findCreatedHelmRelease()
    })
})