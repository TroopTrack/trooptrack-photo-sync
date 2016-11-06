module.exports.connectTo = function connectTo(elmThing) {

  console.log("Connected to Elm!", elmThing);

  elmThing.ports.storeCurrentUser.subscribe(storeCurrentUser);
  elmThing.ports.getCurrentUser.subscribe(getCurrentUser(elmThing));
  elmThing.ports.logout.subscribe(destroyCurrentUser(elmThing));

  function storeCurrentUser(credentials) {
    localStorage.setItem("current_user", JSON.stringify(credentials));
  }

  function getCurrentUser(elmThing) {
    return function getCurrentUserImpl() {
      var user = localStorage.getItem("current_user");
      elmThing.ports.setCurrentUser.send(JSON.parse(user));
    };
  }

  function destroyCurrentUser(elmThing) {
    return function destroyCurrentUserImpl() {
      localStorage.removeItem("current_user");
      elmThing.ports.sessionEnded.send(null);
    };
  }

};
