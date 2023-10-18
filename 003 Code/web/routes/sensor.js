module.exports = (app) => {
    const sensor = require('../controller/sensor.controller.js');
    /**
     * @swagger
     * paths:
     *  /sensor:
     *   post:
     *    tags:
     *    - sensor
     *    description: 센서 값 저장
     *    parameters:
     *    - in: body
     *      name: body
     *      required: true
     *      schema:
     *       properties:
     *          humidity:
     *              type: string
     *          temperature:
     *              type: string
     *          moisture:
     *              type: string
     *    responses:
     *     200:
     *      description: 센서 값 저장 성공
     *      schema:
     *       properties:
     *        success:
     *         type: string
     *
     */
    app.post('/sensor', sensor.create);

    /**
     * @swagger
     * paths:
     *  /sensor:
     *   get:
     *    tags:
     *    - sensor
     *    description: 센서 값 조회
     *    responses:
     *     200:
     *      description: 조회 성공
     *      schema:
     *       properties:
     *        success:
     *         type: string
     *
     */

    app.get('/sensor', sensor.findAll);

    /**
     * @swagger
     * paths:
     *  /sensor/recent:
     *   get:
     *    tags:
     *    - sensor
     *    description: 최근 센서 값 조회
     *    responses:
     *     200:
     *      description: 조회 성공
     *      schema:
     *       properties:
     *        success:
     *         type: string
     *
     */
    app.get('/sensor/recent', sensor.findRecent);

    /**
     * @swagger
     * paths:
     *  /sensor/:sensorId:
     *   delete:
     *    tags:
     *    - sensor
     *    description: 센서 값 삭제
     *    responses:
     *     200:
     *      description: 삭제 성공
     *      schema:
     *       properties:
     *        success:
     *         type: string
     *
     */
    app.delete('/sensor/:sensorId', sensor.delete);
};
