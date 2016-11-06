module Login.Update exposing (..)

import Task exposing (Task)
import Http exposing (Error)
import Json.Decode exposing (Decoder, (:=), string, int, list, object8, at)
import Login.Model as LM exposing (Model)
import Credentials as C
import Ports


type Action
    = Username String
    | Password String
    | Authenticate
    | UserToken (Result Error (List C.User))
    | NoOp


init : String -> ( Model, Cmd action )
init partnerToken =
    ( LM.initialModel partnerToken
    , Cmd.none
    )


update : Action -> Model -> ( Model, Cmd Action )
update action model =
    case action of
        NoOp ->
            ( model, Cmd.none )

        Username s ->
            ( { model | username = s }
            , Cmd.none
            )

        Password s ->
            ( { model | password = s }
            , Cmd.none
            )

        Authenticate ->
            ( { model | authenticating = True }
            , authenticate model
            )

        UserToken result ->
            case result of
                Ok us ->
                    let
                        oldCredentials =
                            model.credentials

                        newCredentials =
                            { oldCredentials | users = us }
                    in
                        ( { model
                            | credentials = newCredentials
                            , password = ""
                            , errorMessage = Nothing
                            , successMessage = Just "Authenticated!"
                            , authenticating = False
                          }
                        , Ports.storeCurrentUser newCredentials
                        )

                Err error ->
                    -- eventually present an error message appropriate for what happened
                    ( { model
                        | errorMessage = Just "oops! couldn't authenticate"
                        , successMessage = Nothing
                        , password = ""
                        , authenticating = False
                      }
                    , Ports.errorNotification "oops! couldn't authenticate"
                    )



-- Cmd


authenticate : Model -> Cmd Action
authenticate model =
    sendAuthRequest model
        |> Task.toResult
        |> Task.perform UserToken UserToken


sendAuthRequest : Model -> Task Error (List C.User)
sendAuthRequest model =
    Http.fromJson authDecoder
        <| Http.send Http.defaultSettings
            { verb = "POST"
            , headers =
                [ ( "X-Partner-Token", model.credentials.partnerToken )
                , ( "X-Username", model.username )
                , ( "X-User-Password", model.password )
                ]
            , url =
                "https://trooptrack.com/api/v1/tokens"
                --, url = "http://trooptrack.dev/api/v1/tokens"
            , body = Http.empty
            }



-- Decoders


authDecoder : Decoder (List C.User)
authDecoder =
    at [ "users" ] userListDecoder


userListDecoder : Decoder (List C.User)
userListDecoder =
    list userDecoder


userDecoder : Decoder C.User
userDecoder =
    object8 C.User
        ("token" := string)
        ("privileges" := list string)
        ("troop" := string)
        ("troop_id" := int)
        ("troop_number" := string)
        ("troop_type" := string)
        ("troop_type_id" := int)
        ("user_id" := int)
