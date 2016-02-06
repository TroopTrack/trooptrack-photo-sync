module App.Update where

import Effects exposing (Effects)

import App.Model as Model

import Login.Update as Login
import PhotoAlbums.Update
import Credentials as C
import Notifications
import Releases
import Pages
import Task


type Action
  = Authentication Login.Action
  | PhotoAlbums PhotoAlbums.Update.Action
  | NoOp
  | CurrentUser (Maybe C.Credentials)
  | ResetSession
  | Notify Notifications.Notification
  | LatestRelease (Maybe Releases.Release)


init : String -> String -> (Model.Model, Effects Action)
init partnerToken version =
  let
    impl =
      ( Model.initialModel partnerToken version
      , Effects.batch
        [ getCurrentUser
        , findLatestRelease
        ]
      )
  in
    impl


update : Action -> Model.Model -> (Model.Model, Effects Action)
update action model =
  case action of

    NoOp ->
      (model, Effects.none)

    LatestRelease maybeRelease ->
      let
        updateTarget =
          Releases.needsUpdate model.version maybeRelease

        baseMessage =
          """
          A new version of TroopTrack Photo Sync is available.
          You can download it here:
          """

        updateLink release =
          "<a href='" ++ release.url ++ "' taget='_blank'>" ++ release.version ++ "</a>"

        updateMessage release =
          baseMessage ++ updateLink release

        updateFx release =
          updateMessage release
            |> Notifications.info
            |> sendNotification
      in
        case updateTarget of
          Nothing ->
            (model, Effects.none)

          Just release ->
            (model, updateFx release)


    Notify notification ->
      ( model
      , sendNotification notification
      )

    ResetSession ->
      let
        token =
          model.loginInfo.credentials.partnerToken

        version =
          model.version.version
      in
        ( Model.initialModel token version
        , getCurrentUser
        )

    CurrentUser maybeCreds ->
      case maybeCreds of

        Nothing ->
          ( { model | page = Pages.LoginPage }
          , Effects.none
          )

        Just creds ->
          let
            loginInfo =
              model.loginInfo

            newLoginInfo =
              { loginInfo | credentials = creds }
          in
            ( { model
              | loginInfo = newLoginInfo
              , page = Pages.PhotoAlbumsPage
              }
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
            Pages.PhotoAlbumsPage

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


findLatestRelease : Effects Action
findLatestRelease =
  Releases.latestVersion
    |> Task.toMaybe
    |> Effects.task
    |> Effects.map LatestRelease


-- Mailboxes

getCurrentUserBox : Signal.Mailbox ()
getCurrentUserBox =
  Signal.mailbox ()
