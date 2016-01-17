module App.View where

import Signal exposing (Address)
import Html as H exposing (Html)

import App.Model exposing (Model)
import App.Update exposing (Action(..))

import Login.View as Login
import PhotoAlbums.View as PhotoAlbums
import Loading.View as Loading
import Pages


view : Address Action -> Model -> Html
view address model =
  case model.page of

    Pages.LoadingPage ->
      Loading.view

    Pages.LoginPage ->
      Login.view
        (Signal.forwardTo address Authentication)
        model.loginInfo

    Pages.PhotoAlbumsPage ->
      PhotoAlbums.view
        (Signal.forwardTo address App.Update.PhotoAlbums)
        model.troopTypes
        model.loginInfo.credentials
        model.photoAlbums
