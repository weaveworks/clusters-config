const {defineConfig} = require("cypress");
const {cloudPlugin} = require("cypress-cloud/plugin");
module.exports = defineConfig({
    e2e: {
        baseUrl: 'https://wge-2448.eng-sandbox.weave.works',
        setupNodeEvents(on, config) {
            return cloudPlugin(on, config);
        },
    },
});
