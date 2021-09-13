const express = require('express');
const app = express();
const port = 3000;

const fs = require('fs');
const bodyParser = require('body-parser')


app.use(bodyParser.urlencoded({ extended: false }));
app.use(express.json());

app.use(function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
});

app.get('/', (req, res) => {
    res.send('Hello World!')
});

app.listen(port, () => {
    console.log(`Experiment Results app listening at http://localhost:${port}`)
});

app.post('/finish', (req, res) => {
    let body = req.body;
    let resultString = "";

    resultString += body.name + " ";
    resultString += body.value + " ";
    resultString += body.input + " ";
    resultString += body.slider + " ";
    resultString += body.time + "\n";



    fs.appendFile('experiment_results.txt', resultString, function (err) {
        if (err) throw err;
        console.log('Saved!');
    });
    res.send('Appended result').status(200)
});