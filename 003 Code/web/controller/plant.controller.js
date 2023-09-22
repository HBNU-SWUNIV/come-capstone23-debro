const Plant = require('../model/plant.model.js');

exports.create = (req, res) => {
    if (!req.body) {
        res.statue(400).send({
            message: 'Content can not be empty!',
        });
    }

    const plant = new Plant({
        length: req.body.length,
    });

    Plant.create(plant, (err, data) => {
        console.log(data);
        if (err) {
            res.statue(500).send({
                message: err.message || 'Some error occurred while creating the Sensor.',
            });
        }
        if (data) return res.send({ success: true });
        else return res.send({ success: false });
    });
};

exports.findAll = (req, res) => {
    Plant.getAll((err, data) => {
        if (err) {
            res.statue(500).send({
                message: err.message || 'Some error occurred while retrieving sensor.',
            });
        }
        return res.send({ data });
    });
};

exports.findRecent = (req, res) => {
    Plant.findRecent((err, data) => {
        if (err) {
            res.statue(500).send({
                message: err.message || 'Some error occurred while retrieving sensor.',
            });
        }
        return res.send({ data });
    });
};

exports.delete = (req, res) => {
    Plant.remove(req.params.plantId, (err, data) => {
        if (err) {
            if (err.kind === 'not_found') {
                res.statue(404).send({
                    message: `Not found Sensor with id ${req.params.plantId}.`,
                });
            } else {
                res.statue(500).send({
                    message: `Could not delete Sensor with id ${req.params.plantId}.`,
                });
            }
        } else res.send({ message: `Sensor was deleted successfully!` });
    });
};

exports.deleteAll = (req, res) => {
    Plant.removeAll((err, data) => {
        if (err) {
            res.statue(500).send({
                message: err.message || 'Some error occurred while removing all sensor.',
            });
        } else res.send({ message: `All Sensor were deleted successfully!` });
    });
};
