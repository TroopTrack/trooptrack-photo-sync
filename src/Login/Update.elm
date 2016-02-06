module Login.Update where

import Effects exposing (Effects)
import Task exposing (Task)
import Http exposing (Error)
import Json.Decode exposing (Decoder, (:=), string, int, list, object8, at)

import Login.Model as LM exposing (Model)
import Credentials as C
import Notifications

type Action
  = Username String
  | Password String
  | Authenticate
  | UserToken (Result Error (List C.User))
  | NoOp


init : String -> (Model, Effects action)
init partnerToken =
  ( LM.initialModel partnerToken
  , Effects.none
  )


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of

    NoOp ->
      (model, Effects.none)

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
                , password = ""
                , errorMessage = Nothing
                , successMessage = Just "Authenticated!"
              }
            , storeCurrentUser newCredentials
            )

        Err error ->
          -- eventually present an error message appropriate for what happened
          ( { model |
                errorMessage = Just "oops! couldn't authenticate"
              , successMessage = Nothing
              , password = ""
              , authenticating = False
            }
          , errorNotification "oops! couldn't authenticate"
          )


-- Effects


authenticate : Model -> Effects Action
authenticate model =
  sendAuthRequest model
    |> Task.toResult
    |> Task.map UserToken
    |> Effects.task


sendAuthRequest : Model -> Task Error (List C.User)
sendAuthRequest model =
  Http.fromJson authDecoder
    <| Http.send Http.defaultSettings
        { verb = "POST"
        , headers =
            [ ("X-Partner-Token", model.credentials.partnerToken)
            , ("X-Username", model.username)
            , ("X-User-Password", model.password)
            ]
        , url = "https://trooptrack.com/api/v1/tokens"
        --, url = "http://trooptrack.dev/api/v1/tokens"
        , body = Http.empty
        }


storeCurrentUser : C.Credentials -> Effects Action
storeCurrentUser credentials =
  Signal.send storeUsersBox.address credentials
    |> Effects.task
    |> Effects.map (always NoOp)


errorNotification : String -> Effects Action
errorNotification message =
  let
    notifications = Notifications.notifications
  in
    Notifications.error message
      |> Signal.send notifications.address
      |> Effects.task
      |> Effects.map (always NoOp)


-- Decoders

authDecoder : Decoder (List C.User)
authDecoder =
  at ["users"] userListDecoder


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

-- Mailboxes

storeUsersBox : Signal.Mailbox C.Credentials
storeUsersBox =
  Signal.mailbox <| C.initialCredentials ""
