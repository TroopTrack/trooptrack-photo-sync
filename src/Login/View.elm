module Login.View where

import Signal exposing (Address)

import Html exposing (Html, Attribute, form, div, h4, input, text, p, a, label, button)
import Html.Attributes exposing (type', placeholder, href, class, value, disabled)
import Html.Events exposing (on, targetValue, onClick)

import Layouts

import Login.Update exposing (Action(..))
import Login.Model exposing (Model)

view : Address Action -> Model -> Html
view address model =
  Layouts.centered [ viewContent address model ]

viewContent : Address Action -> Model -> Html
viewContent address model =
  div [ class "row column log-in-form" ]
    [ h4 [ class "text-center" ] [ text "Log in with your user name" ]
    , errorMessage model
    , successMessage model
    , field "User name"
        [ type' "text"
        , placeholder "Your user name"
        , on "input" targetValue (toMessage address Username)
        , value model.username
        ]
    , field "Password"
        [ type' "password"
        , placeholder "Password"
        , on "input" targetValue (toMessage address Password)
        , value model.password
        ]
    , submitButton address model
    , forgotPassword
    ]

errorMessage : Model -> Html
errorMessage model =
  case model.errorMessage of
    Nothing ->
      div [ class "text-center" ] []

    Just msg ->
      div [ class "text-center alert callout" ] [ text msg ]

successMessage : Model -> Html
successMessage model =
  case model.successMessage of
    Nothing ->
      div [ class "text-center" ] []

    Just msg ->
      div [ class "text-center success callout" ] [ text msg ]

field : String -> List Attribute -> Html
field name attributes =
  label []
    [ text name
    , input attributes []
    ]

submitButton : Address Action -> Model -> Html
submitButton address model =
  let
    buttonText =
      case model.authenticating of
        True ->
          "Please wait..."

        False ->
          "Log in"
  in
    p []
      [ button
          [ class "button expanded"
          , disabled model.authenticating
          , onClick address Authenticate
          ]
          [ text buttonText ]
      ]

forgotPassword : Html
forgotPassword =
  p [ class "text-center" ]
    [ a [ href "#" ]
        [ text "Forgot your password?" ]
    ]

toMessage : Address action -> (b -> action) -> b -> Signal.Message
toMessage address toAction val =
  Signal.message address (toAction val)