module.exports = (app) => {
    const sensor = require('../controller/sensor.controller.js');

    app.post('/sensor', sensor.create);

    app.get('/sensor', sensor.findAll);

    app.get('/sensor/recent', sensor.findRecent);

    app.delete('/sensor/:sensorId', sensor.delete);
};
