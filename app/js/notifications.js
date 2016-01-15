/* jslint esnext: true, node: true */
module.exports = function notifications(elmThing) {

  const toastr = require('toastr');


  elmThing.ports.notifications.subscribe(handleNotifications(elmThing));


  function handleNotifications(elmThing) {
    return function handleNotificationsImpl(msg) {
      console.log(msg);

      if (msg.msgType === "error") {
        toastr.error(msg.message);
      }
      else {
        console.log("WAT!?", msg);
      }
    };
  }

};
