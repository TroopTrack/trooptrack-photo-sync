/* jslint esnext: true, node: true */
module.exports = function config(callback) {


  const fs = require('fs');
  const configFile = __dirname + "/../../config.json";


  fs.readFile(configFile, (err, data) => {
    if (err) console.error(err);
    else handleConfig(data, callback);
  });


  function handleConfig(data, callback) {
    var options = JSON.parse(data);
    return callback(options);
  }


};
