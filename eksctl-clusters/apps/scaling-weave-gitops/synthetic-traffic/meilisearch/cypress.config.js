// eslint-disable-next-line import/no-extraneous-dependencies
const {defineConfig} = require('cypress')

module.exports = defineConfig({
    viewportWidth: 1440,
    viewportHeight: 900,
    env: {
        host: 'http://0.0.0.0:7700',
        apiKey: 'masterKey',
        wrongApiKey: 'wrongApiKey',
        waitingTime: 1000,
    },
    e2e: {
        baseUrl: 'http://meilisearch.meilisearch.svc.cluster.local:7700/',
        specPattern: 'cypress/e2e/**/*.{js,jsx,ts,tsx}',
    },
})
