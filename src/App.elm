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
import Notifications
import External


app : StartApp.App Model
app =
  StartApp.start
    { init = init partnerToken
    , update = update
    , view = view
    , inputs =
      [ setCurrentUserSignal
      , updateDownloadProgress
      , cancelDownload
      , resetSessionSignal
      , Signal.map App.Update.Notify externalNotifications
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


port endSession : Signal ()
port endSession =
  let
    sessionEnder = PhotoAlbums.Update.endSession
  in
    sessionEnder.signal


port getCurrentUserSignal : Signal ()
port getCurrentUserSignal =
  getCurrentUserBox.signal


port startPhotoDownload : Signal PhotoAlbums.Model.Photo
port startPhotoDownload =
  photoDownloader.signal


port startAlbumDownload : Signal (List PhotoAlbums.Model.Photo)
port startAlbumDownload =
  albumDownloader.signal


port notifications : Signal Notifications.Notification
port notifications =
  let
    notifier = Notifications.notifications
  in
    notifier.signal


port openExternal : Signal String
port openExternal =
  let
    external = External.openExternal
  in
    external.signal


{-
Ports -- Incoming
-}


port partnerToken : String


port setCurrentUser : Signal (Maybe (C.Credentials))


setCurrentUserSignal : Signal App.Update.Action
setCurrentUserSignal =
  Signal.map App.Update.CurrentUser setCurrentUser


port sessionEnded : Signal ()


resetSessionSignal : Signal App.Update.Action
resetSessionSignal =
  Signal.map (always App.Update.ResetSession) sessionEnded


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


port errorNotifications : Signal String

externalNotifications : Signal Notifications.Notification
externalNotifications =
  Signal.map Notifications.error errorNotifications
