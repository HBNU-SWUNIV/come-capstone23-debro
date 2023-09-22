const swaggerUi = require('swagger-ui-express');
const swaggereJsdoc = require('swagger-jsdoc');

const options = {
    swaggerDefinition: {
        info: {
            title: 'Debro API',
            version: '1.0.0',
            // description: 'Capstone with Debro',
        },
        host: 'localhost:3300',
        basePath: '/',
    },
    apis: ['./routes/*.js', './swagger/*'],
};

const specs = swaggereJsdoc(options);

module.exports = {
    swaggerUi,
    specs,
};
