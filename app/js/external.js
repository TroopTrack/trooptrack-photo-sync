/* jslint esnext: true, node: true */
module.exports = function external(elmThing) {


  elmThing.ports.openExternal.subscribe(openExternal);


  const shell = require('electron').shell;


  function openExternal(url) {
    shell.openExternal(url);
  }
  

};
