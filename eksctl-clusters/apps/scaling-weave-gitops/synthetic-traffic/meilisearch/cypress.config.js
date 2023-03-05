const {defineConfig} = require("cypress");

module.exports = defineConfig({
    e2e: {
        baseUrl: 'http://meilisearch.meilisearch.svc.cluster.local:7700/',
    },
});
