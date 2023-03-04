const {defineConfig} = require("cypress");

module.exports = defineConfig({
    e2e: {
        baseUrl: 'https://wge-2448.eng-sandbox.weave.works',
    },
});
