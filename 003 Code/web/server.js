var createError = require('http-errors');
var express = require('express');
var path = require('path');

var indexRouter = require('./routes/index');
const bodyParser = require('body-parser');
// const dotenv = require('dotenv');

// dotenv.config('dotenv');

var app = express();
var port = 3000;
// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

app.use(express.urlencoded({ extended: false }));
app.use(express.static(path.join(__dirname, 'public')));

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.use('/', indexRouter);

require('./routes/sensor.js')(app);

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`);
});

// module.exports = app;
