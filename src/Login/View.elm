module Login.View exposing (..)

import Html as H exposing (Html, Attribute)
import Html.Attributes as A
import Html.Events as E exposing (on, targetValue, onClick)
import Layouts
import Login.Update exposing (Action(..))
import Login.Model exposing (Model)


view : Model -> Html Action
view model =
    Layouts.centered <| viewContent model


viewContent : Model -> Html Action
viewContent model =
    H.div []
        [ field "Username"
            [ A.type' "text"
            , E.onInput Username
            , A.value model.username
            ]
        , field "Password"
            [ A.type' "password"
            , E.onInput Password
            , A.value model.password
            ]
        , submitButton model
        , forgotPassword
        , termsOfService
        ]


errorMessage : Model -> Html a
errorMessage model =
    case model.errorMessage of
        Nothing ->
            H.div [] []

        Just msg ->
            H.div [] [ H.text msg ]


successMessage : Model -> Html a
successMessage model =
    case model.successMessage of
        Nothing ->
            H.div [ A.class "text-center" ] []

        Just msg ->
            H.div [ A.class "text-center success callout" ] [ H.text msg ]


field : String -> List (Attribute a) -> Html a
field name attributes =
    let
        enhancedAttributes =
            [ A.placeholder name ] ++ attributes
    in
        H.input enhancedAttributes []


submitButton : Model -> Html Action
submitButton model =
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
                , onClick Authenticate
                ]
                [ H.text buttonText ]
            ]


forgotPassword : Html a
forgotPassword =
    let
        usernameUrl =
            "https://trooptrack.com/forgot_user_names/new"

        passwordUrl =
            "https://trooptrack.com/password_resets/new"
    in
        H.p []
            [ H.a
                [ A.href passwordUrl
                ]
                [ H.text "Forgot your password?" ]
            , H.text "|"
            , H.a
                [ A.href usernameUrl
                ]
                [ H.text "Forgot your username?" ]
            ]


termsOfService : Html a
termsOfService =
    let
        termsOfService =
            "https://trooptrack.com/terms_of_service"

        privacy =
            "https://trooptrack.com/privacy"
    in
        H.div []
            [ H.text "Use of this site constitutes acceptance of our"
            , H.br [] []
            , H.a
                [ A.href termsOfService
                ]
                [ H.text "Terms of Service" ]
            , H.text " and "
            , H.a
                [ A.href privacy
                ]
                [ H.text "Privacy Policy" ]
            , H.br [] []
            , H.br [] []
            , H.text "© 2008 - 2016 TroopTrack LLC."
            ]
