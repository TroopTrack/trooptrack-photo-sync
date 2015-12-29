module App.Update where

import Effects exposing (Effects)

import App.Model exposing (Model, Page(..), initialModel)

import Login.Update as Login

type Action
  = Authentication Login.Action


init : (Model, Effects Action)
init =
  ( initialModel
  , Effects.none
  )


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of

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