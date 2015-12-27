module Login.Update where

import Effects exposing (Effects)
import Task exposing (Task)
import Http exposing (Error)
import Json.Decode exposing (Decoder, (:=), string, int, list, object8, at)

import Login.Model exposing (Model, User, initialModel)

type Action
  = Username String
  | Password String
  | Authenticate
  | UserToken (Result Error (List User))

init : (Model, Effects action)
init =
  ( initialModel
  , Effects.none
  )

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of

    Username s ->
      ( { model | username = s }
      , Effects.none
      )

    Password s ->
      ( { model | password = s }
      , Effects.none
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
            ( { model |
                  credentials = newCredentials
                , errorMessage = Nothing
                , successMessage = Just "Authenticated!"
              }
            , Effects.none -- eventually store creds and go to next page
            )

        Err error ->
          -- eventually present an error message appropriate for what happened
          ( { model |
                errorMessage = Just "oops! couldn't authenticate"
              , successMessage = Nothing
              , authenticating = False
            }
          , Effects.none
          )


-- Http

authenticate : Model -> Effects Action
authenticate model =
  sendAuthRequest model
    |> Task.toResult
    |> Task.map UserToken
    |> Effects.task

sendAuthRequest : Model -> Task Error (List User)
sendAuthRequest model =
  Http.fromJson authDecoder
    <| Http.send Http.defaultSettings
        { verb = "POST"
        , headers =
            [ ("X-Partner-Token", model.credentials.partnerToken)
            , ("X-Username", model.username)
            , ("X-User-Password", model.password)
            ]
        , url = "http://trooptrack.dev/api/v1/tokens"
        , body = Http.empty
        }

-- Decoders

authDecoder : Decoder (List User)
authDecoder =
  at ["users"] userListDecoder

userListDecoder : Decoder (List User)
userListDecoder =
  list userDecoder

userDecoder : Decoder User
userDecoder =
  object8 User
    ("token" := string)
    ("privileges" := list string)
    ("troop" := string)
    ("troop_id" := int)
    ("troop_number" := string)
    ("troop_type" := string)
    ("troop_type_id" := int)
    ("user_id" := int)