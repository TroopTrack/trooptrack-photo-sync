module App.View where

import Signal exposing (Address)
import Html as H exposing (Html)

import App.Model exposing (Model, Page(..))
import App.Update exposing (Action(..))

import Login.View as Login
import PhotoAlbum.View as PhotoAlbum

view : Address Action -> Model -> Html
view address model =
  case model.page of

    LoginPage ->
      Login.view
        (Signal.forwardTo address Authentication)
        model.loginInfo

    PhotoAlbumPage ->
      PhotoAlbum.view