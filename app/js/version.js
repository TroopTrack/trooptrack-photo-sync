/* jslint esnext: true, node: true */
module.exports = function version() {


  var app = require('electron').remote.app;
  var versionString = app.getVersion() || "0.0.0";
  return "v" + versionString;


};
