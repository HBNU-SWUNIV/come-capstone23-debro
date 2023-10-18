const sql = require('../routes/db.js');

const Plant = function (plant) {
    this.length = plant.length;
};

Plant.create = (newPlant, result) => {
    sql.query('SELECT * FROM plant_data', (err, res) => {
        if (err) {
            console.log('error: ', err);
            result(null, err);
            return;
        }
        if (res.length == 0) {
            sql.query('INSERT INTO plant_data SET ?', newPlant, (err, res) => {
                if (err) {
                    console.log('error: ', err);
                    result(err, null);
                    return;
                }
                result(null, { id: res.insertId, ...newPlant });
            });
        } else if (newPlant.length > res[res.length - 1].length) {
            sql.query('INSERT INTO plant_data SET ?', newPlant, (err, res) => {
                if (err) {
                    console.log('error: ', err);
                    result(err, null);
                    return;
                }
                result(null, { id: res.insertId, ...newPlant });
            });
        } else {
            result(null, null);
            return;
        }
    });
};

Plant.findRecent = (result) => {
    sql.query('SELECT * FROM plant_data', (err, res) => {
        if (err) {
            console.log('error: ', err);
            result(null, err);
            return;
        }
        console.log('plant: ', res[res.length - 1]);
        result(null, res[res.length - 1]);
    });
};

Plant.getAll = (result) => {
    sql.query('SELECT * FROM plant_data', (err, res) => {
        if (err) {
            console.log('error: ', err);
            result(null, err);
            return;
        }
        console.log('sensor: ', res);
        result(null, res);
    });
};

Plant.remove = (plantID, result) => {
    sql.query('DELETE FROM plant_data WHERE id = ?', plantID, (err, res) => {
        if (err) {
            console.log('error: ', err);
            result(err, null);
            return;
        }

        if (res.affectedRows == 0) {
            // 결과가 없을 시
            result({ kind: 'not_found' }, null);
            return;
        }

        console.log('deleted customer with id: ', sensorID);
        result(null, res);
    });
};

module.exports = Plant;
