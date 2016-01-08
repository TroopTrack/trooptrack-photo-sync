module App.View where

import Signal exposing (Address)
import Html as H exposing (Html)

import App.Model exposing (Model, Page(..))
import App.Update exposing (Action(..))

import Login.View as Login
import PhotoAlbums.View as PhotoAlbums
import Loading.View as Loading

view : Address Action -> Model -> Html
view address model =
  case model.page of

    LoadingPage ->
      Loading.view

    LoginPage ->
      Login.view
        (Signal.forwardTo address Authentication)
        model.loginInfo

    PhotoAlbumsPage ->
      PhotoAlbums.view
        (Signal.forwardTo address App.Update.PhotoAlbums)
        model.loginInfo.credentials
        model.photoAlbums
