module App.Update where

import Effects exposing (Effects)

import App.Model exposing (Model, Page(..), initialModel)

import Login.Update as Login
import PhotoAlbums.Update
import Credentials as C
import Notifications


type Action
  = Authentication Login.Action
  | PhotoAlbums PhotoAlbums.Update.Action
  | NoOp
  | CurrentUser (Maybe C.Credentials)
  | ResetSession
  | Notify Notifications.Notification


init : (Model, Effects Action)
init =
  ( initialModel
  , getCurrentUser
  )


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of

    NoOp ->
      (model, Effects.none)

    Notify notification ->
      ( model
      , sendNotification notification
      )

    ResetSession ->
      ( initialModel
      , getCurrentUser
      )

    CurrentUser maybeCreds ->
      case maybeCreds of
        Nothing ->
          ( { model | page = LoginPage }
          , Effects.none
          )

        Just creds ->
          let
            loginInfo =
              model.loginInfo

            newLoginInfo =
              { loginInfo | credentials = creds }
          in
            ( { model | loginInfo = newLoginInfo, page = PhotoAlbumsPage }
            , Effects.none
            )

    Authentication creds ->
      let
        (login, fx) =
          Login.update creds model.loginInfo

        users =
          login.credentials.users

        page =
          if List.isEmpty users then
            model.page
          else
            PhotoAlbumsPage

      in
        ( { model | loginInfo = login, page = page }
        , Effects.map Authentication fx
        )

    PhotoAlbums photoAlbumAct ->
      let
        credentials =
          model.loginInfo.credentials

        (newPhotoAlbums, fx) =
          PhotoAlbums.Update.update photoAlbumAct credentials.partnerToken model.photoAlbums

      in
        ( { model | photoAlbums = newPhotoAlbums }
        , Effects.map PhotoAlbums fx
        )


--- Effects

getCurrentUser : Effects Action
getCurrentUser =
  Signal.send getCurrentUserBox.address ()
    |> Effects.task
    |> Effects.map (always NoOp)


sendNotification : Notifications.Notification -> Effects Action
sendNotification notification =
  let
    notifier = Notifications.notifications
  in
    Signal.send notifier.address notification
      |> Effects.task
      |> Effects.map (always NoOp)

-- Mailboxes

getCurrentUserBox : Signal.Mailbox ()
getCurrentUserBox =
  Signal.mailbox ()
