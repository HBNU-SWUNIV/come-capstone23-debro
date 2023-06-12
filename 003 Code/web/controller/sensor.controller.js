const Sensor = require('../model/sensor.model.js');

exports.create = (req, res) => {
    if (!req.body) {
        res.statue(400).send({
            message: 'Content can not be empty!',
        });
    }

    const sensor = new Sensor({
        humidity: req.body.humidity,
        temperature: req.body.temperature,
        moisture: req.body.moisture,
        ph: req.body.ph,
    });

    Sensor.create(sensor, (err, data) => {
        if (err) {
            res.statue(500).send({
                message: err.message || 'Some error occurred while creating the Sensor.',
            });
        }
        return res.send({ success: true });
    });
};

exports.findAll = (req, res) => {
    Sensor.getAll((err, data) => {
        if (err) {
            res.statue(500).send({
                message: err.message || 'Some error occurred while retrieving sensor.',
            });
        }
        return res.send({ data });
    });
};

exports.findRecent = (req, res) => {
    Sensor.findRecent((err, data) => {
        if (err) {
            res.statue(500).send({
                message: err.message || 'Some error occurred while retrieving sensor.',
            });
        }
        return res.send({ data });
    });
};

exports.delete = (req, res) => {
    Sensor.remove(req.params.sensorId, (err, data) => {
        if (err) {
            if (err.kind === 'not_found') {
                res.statue(404).send({
                    message: `Not found Sensor with id ${req.params.sensorId}.`,
                });
            } else {
                res.statue(500).send({
                    message: `Could not delete Sensor with id ${req.params.sensorId}.`,
                });
            }
        } else res.send({ message: `Sensor was deleted successfully!` });
    });
};

exports.deleteAll = (req, res) => {
    Sensor.removeAll((err, data) => {
        if (err) {
            res.statue(500).send({
                message: err.message || 'Some error occurred while removing all sensor.',
            });
        } else res.send({ message: `All Sensor were deleted successfully!` });
    });
};
