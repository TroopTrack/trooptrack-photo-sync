module Login.View where

import Signal exposing (Address)

import Html as H exposing (Html, Attribute)
import Html.Attributes as A
import Html.Events exposing (on, targetValue, onClick)

import Layouts

import Login.Update exposing (Action(..))
import Login.Model exposing (Model)


view : Address Action -> Model -> Html
view address model =
  Layouts.centered <| viewContent address model


viewContent : Address Action -> Model -> Html
viewContent address model =
  H.div
    []
    [ field "Username"
        [ A.type' "text"
        , on "input" targetValue (toMessage address Username)
        , A.value model.username
        ]
    , field "Password"
        [ A.type' "password"
        , on "input" targetValue (toMessage address Password)
        , A.value model.password
        ]
    , submitButton address model
    , forgotPassword
    ]


errorMessage : Model -> Html
errorMessage model =
  case model.errorMessage of
    Nothing ->
      H.div [] []

    Just msg ->
      H.div [] [ H.text msg ]


successMessage : Model -> Html
successMessage model =
  case model.successMessage of
    Nothing ->
      H.div [ A.class "text-center" ] []

    Just msg ->
      H.div [ A.class "text-center success callout" ] [ H.text msg ]


field : String -> List Attribute -> Html
field name attributes =
  let
    enhancedAttributes =
      [ A.placeholder name ] ++ attributes
  in
    H.input enhancedAttributes []


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
    H.p []
      [ H.button
          [ A.class "button expanded"
          , A.disabled model.authenticating
          , onClick address Authenticate
          ]
          [ H.text buttonText ]
      ]


forgotPassword : Html
forgotPassword =
  H.p [ A.class "text-center" ]
    [ H.a
      [ A.href "#" ]
      [ H.text "Forgot your password?" ]
    ]


toMessage : Address action -> (b -> action) -> b -> Signal.Message
toMessage address toAction val =
  Signal.message address (toAction val)
