module.exports = (app) => {
    const plant = require('../controller/plant.controller.js');

    /**
     * @swagger
     * paths:
     *  /plant:
     *   post:
     *    tags:
     *    - sensor
     *    description: 길이 저장
     *    parameters:
     *    - in: body
     *      name: body
     *      required: true
     *      schema:
     *       properties:
     *          length:
     *              type: string
     *    responses:
     *     200:
     *      description: 저장 성공
     *      schema:
     *       properties:
     *        success:
     *         type: string
     *
     */
    app.post('/plant', plant.create);

    /**
     * @swagger
     * paths:
     *  /plant:
     *   get:
     *    tags:
     *    - plant
     *    description: 길이 조회
     *    responses:
     *     200:
     *      description: 조회 성공
     *      schema:
     *       properties:
     *        success:
     *         type: string
     *
     */

    app.get('/plant', plant.findAll);

    /**
     * @swagger
     * paths:
     *  /plant/recent:
     *   get:
     *    tags:
     *    - plant
     *    description: 최근 길이 조회
     *    responses:
     *     200:
     *      description: 조회 성공
     *      schema:
     *       properties:
     *        success:
     *         type: string
     *
     */

    app.get('/plant/recent', plant.findRecent);

    /**
     * @swagger
     * paths:
     *  /plant/:plantId:
     *   delete:
     *    tags:
     *    - plant
     *    description: 길이 값 삭제
     *    responses:
     *     200:
     *      description: 삭제 성공
     *      schema:
     *       properties:
     *        success:
     *         type: string
     *
     */
    app.delete('/plant/:plantId', plant.delete);
};
