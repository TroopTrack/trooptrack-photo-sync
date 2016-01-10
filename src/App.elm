module App where

import StartApp
import Task
import Effects exposing (Effects)
import Html

import App.Model exposing (Model)
import App.View exposing (view)
import App.Update exposing (update, init, getCurrentUserBox)

import Credentials as C
import Login.Update exposing (storeUsersBox)
import PhotoAlbums.Update exposing (photoDownloader, albumDownloader)
import PhotoAlbums.Model


app : StartApp.App Model
app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs =
      [ setCurrentUserSignal
      , updateDownloadProgress
      , cancelDownload
      ]
    }


main : Signal Html.Html
main =
  app.html


{-
Ports - Outgoing
-}


port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks


port storeUsersSignal : Signal C.Credentials
port storeUsersSignal =
  storeUsersBox.signal


port getCurrentUserSignal : Signal ()
port getCurrentUserSignal =
  getCurrentUserBox.signal


port startPhotoDownload : Signal PhotoAlbums.Model.Photo
port startPhotoDownload =
  photoDownloader.signal


port startAlbumDownload : Signal (List PhotoAlbums.Model.Photo)
port startAlbumDownload =
  albumDownloader.signal


{-
Ports -- Incoming
-}


port setCurrentUser : Signal (Maybe (C.Credentials))


setCurrentUserSignal : Signal App.Update.Action
setCurrentUserSignal =
  Signal.map App.Update.CurrentUser setCurrentUser


port downloadProgress : Signal (Float, PhotoAlbums.Model.Photo)

updateDownloadProgress : Signal App.Update.Action
updateDownloadProgress =
  let
    progress =
      Signal.map PhotoAlbums.Update.DownloadProgress downloadProgress
  in
    Signal.map App.Update.PhotoAlbums progress


port cancelledDownload : Signal PhotoAlbums.Model.Photo

cancelDownload : Signal App.Update.Action
cancelDownload =
  let
    cancels =
      Signal.map PhotoAlbums.Update.CancelDownload cancelledDownload
  in
    Signal.map App.Update.PhotoAlbums cancels
