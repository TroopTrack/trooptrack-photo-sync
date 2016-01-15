module.exports.connectTo = function connectTo(elmThing) {

  console.log("Connected to Elm!", elmThing);

  elmThing.ports.storeUsersSignal.subscribe(storeCurrentUser);
  elmThing.ports.getCurrentUserSignal.subscribe(getCurrentUser(elmThing));
  elmThing.ports.endSession.subscribe(destroyCurrentUser(elmThing));

};


var userDb = new PouchDB("dbs/photo_sync_users", {adapter: 'websql'});


function storeCurrentUser(credentials) {
  userDb.get('current_user').then(function(doc) {

    return userDb.put(credentials, 'current_user', doc._rev);

  }).then(function(response) {

    // TODO: send results back into Elm App.
    console.log(response);

  }).catch(function(err) {

    if (err.status === 404) {

      userDb.put(credentials, 'current_user').then(function(response) {
        return console.log("First login!", response);
      });

    } else {

      // TODO: send errors back into Elm App.
      console.error(err);

    }

  });
}


function getCurrentUser(elmThing) {
  return function getCurrentUserImpl() {

    userDb.get("current_user").then(function(doc) {

      return elmThing.ports.setCurrentUser.send(doc);

    }).catch(function(error) {

      console.log("No current user", error);
      return elmThing.ports.setCurrentUser.send(null);

    });
  };
}


function destroyCurrentUser(elmThing) {
  return function destroyCurrentUserImpl() {
    console.log("Removing user!");

    userDb.get("current_user").then(function(doc) {
      userDb.remove(doc);
    }).then(function() {
      return elmThing.ports.sessionEnded.send([]);
    }).catch(function(error) {
      return console.log("Error logging out", error);
    });
  };
}
