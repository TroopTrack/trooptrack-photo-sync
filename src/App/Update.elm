module App.Update where

import Effects exposing (Effects)

import App.Model exposing (Model, Page(..), initialModel)

import Login.Update as Login
import PhotoAlbum.Update
import Credentials as C


type Action
  = Authentication Login.Action
  | PhotoAlbums PhotoAlbum.Update.Action
  | NoOp
  | CurrentUser (Maybe C.Credentials)


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
            ( { model | loginInfo = newLoginInfo, page = PhotoAlbumPage }
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
            PhotoAlbumPage

      in
        ( { model | loginInfo = login, page = page }
        , Effects.map Authentication fx
        )

    PhotoAlbums photoAlbumAct ->
      let
        credentials =
          model.loginInfo.credentials

        (newPhotoAlbum, fx) =
          PhotoAlbum.Update.update photoAlbumAct credentials.partnerToken model.photoAlbum
      in
        ( { model | photoAlbum = newPhotoAlbum }
        , Effects.map PhotoAlbums fx
        )


--- Effects

getCurrentUser : Effects Action
getCurrentUser =
  Signal.send getCurrentUserBox.address ()
    |> Effects.task
    |> Effects.map (always NoOp)

-- Mailboxes

getCurrentUserBox : Signal.Mailbox ()
getCurrentUserBox =
  Signal.mailbox ()