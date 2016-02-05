/* jslint esnext: true, node: true */
module.exports = function downloads(elmThing) {

  const BrowserWindow = require('electron').remote.BrowserWindow;
  const dialog = require('electron').remote.dialog;
  const userHome = require('user-home');
  const Path = require('path');
  const mkdirp = require('mkdirp');
  const fs = require('fs');
  const request = require('request');
  const progress = require('request-progress');
  const async = require('async');


  var downloadsQ = async.queue(function(task, callback) {
    downloadPhoto(task.baseDirectory, task.photo);
    callback();
  }, 2);


  elmThing.ports.startPhotoDownload.subscribe(handlePhotoDownloads);
  elmThing.ports.startAlbumDownload.subscribe(handleAlbumDownloads);


  function handlePhotoDownloads(photo) {
    askForDirectory(function(baseDirectory) {
      if (baseDirectory) downloadPhoto(baseDirectory, photo);
      else cancelDownloads([photo]);
    });
  }


  function handleAlbumDownloads(photos) {
    askForDirectory(function(baseDirectory) {
      if (baseDirectory) downloadPhotos(baseDirectory, photos);
      else cancelDownloads(photos);
    });
  }


  function askForDirectory(callback) {
    var win = BrowserWindow.getFocusedWindow();
    var paths = dialog.showOpenDialog(
      win,
      { title : "Export Directory",
        defaultPath : userHome,
        properties : [ 'openDirectory' ]
      }
    );
    var path = paths ? paths[0] : null;
    return callback(path);
  }


  function cancelDownloads(photos) {
    for (var photo of photos) {
      elmThing.ports.cancelledDownload.send(photo);
    }
  }


  function downloadPhotos(baseDirectory, photos) {
    for (var photo of photos) {
      queueDownload(baseDirectory, photo);
    }
  }


  function queueDownload(baseDirectory, photo) {
    downloadsQ.push({
      baseDirectory: baseDirectory,
      photo: photo
    });
  }


  function downloadPhoto(baseDirectory, photo) {
    createDirectories(baseDirectory, photo, function(err, filePath) {
      if (err) console.error(err.message);
      else writePhoto(filePath, photo);
    });
  }


  function createDirectories(baseDirectory, photo, callback) {
    var fullPath = photoPath(baseDirectory, photo);
    mkdirp(Path.dirname(fullPath), function(err) {
      callback(err, fullPath);
    });
  }


  function photoPath(baseDirectory, photo) {
    var path = photo.path.join(Path.sep);
    return Path.join(baseDirectory, path);
  }


  function writePhoto(filePath, photo) {
    progress(request(photo.photoUrl))
    .on('response', function(response) {

      if (response.statusCode === 404) {

        console.log("no file!!!");
        elmThing.ports.errorNotifications.send(
          "File not available. " +
          "Failed to write: " + filePath
        );
        return false;

      } else {

        return true;

      }

    }).on('error', function (err) {

      // TODO: Send an error notification through elm
      console.error("We should send this into Elm:", err);
      elmThing.ports.errorNotifications.send(err.message);
      return false;

    }).on('progress', function (state) {

      // The state is an object that looks like this:
      // {
      //     percentage: 0.5,              // Overall percentage between 0 to 1 ()
      //     speed: 554732,             // The download speed in bytes/sec
      //     size: {
      //         total: 90044871,       // The total payload size in bytes
      //         transferred: 27610959  // The transferred payload size in bytes
      //     },
      //     time: {
      //         elapsed: 36.2356,      // The total elapsed seconds since the start (3 decimals)
      //         remaining: 81.4032     // The remaining seconds to finish (3 decimals)
      //     }
      // }

      elmThing.ports.downloadProgress.send([state.percentage, photo]);

    }).on('end', function(err) {

      elmThing.ports.downloadProgress.send([100.0, photo]);

    }).pipe(fs.createWriteStream(filePath));
  }


};
