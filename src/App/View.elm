module App.View where

import Signal exposing (Address)
import Html exposing (Html)

import App.Model exposing (Model, Page(..))
import App.Update exposing (Action(..))

import Login.View as Login

view : Address Action -> Model -> Html
view address model =
  case model.page of

    LoginPage ->
      Login.view
        (Signal.forwardTo address Authentication)
        model.loginInfo

    TroopSelectionPage ->
      Html.text "This will be a troop selection page"