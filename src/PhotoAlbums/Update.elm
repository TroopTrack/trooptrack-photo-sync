module PhotoAlbums.Update where

import Http exposing (Error(..))
import Json.Decode as Json exposing ((:=))

import Credentials as C
import Effects exposing (Effects)
import Task exposing (Task)

import PhotoAlbums.Model as Model exposing (Model, PhotoAlbum, Photo)

import Erl
import Dict


type Action
  = LoadPhotoAlbums C.User
  | DisplayPhotoAlbums (Result Error (List PhotoAlbum))
  | DisplayTroopSelection
  | UpdatePhotoAlbum (Result Error PhotoAlbum)
  | CurrentAlbum (Maybe PhotoAlbum)
  | DownloadPhoto Photo
  | DownloadAlbum PhotoAlbum
  | DownloadProgress (Float, Photo)
  | DownloadComplete Photo
  | CancelDownload Photo
  | SetMenuState Model.MenuState
  | Logout
  | NoOp

update : Action -> String -> Model -> (Model, Effects Action)
update action partnerToken model =
  case action of

    NoOp ->
      (model, Effects.none)

    Logout ->
      ( model, logout )

    SetMenuState state ->
      ( { model | menuState = state }
      , Effects.none
      )

    CurrentAlbum album ->
      ( { model | currentAlbum = album, menuState = Model.MenuOff }
      , Effects.none
      )

    LoadPhotoAlbums user ->
      ( updateUser (Just user) model
      , loadPhotoAlbums partnerToken user
      )

    DisplayTroopSelection ->
      let
        newModel =
          updateUser Nothing model
      in
        ( { newModel | menuState = Model.MenuOff }
        , Effects.none
        )

    DisplayPhotoAlbums result ->
      case result of
        Ok albums ->
          ( { model
            | photoAlbums = albums
            , errorMessage = Nothing
            }
          , Effects.batch
              <| List.map (fetchAlbumDetails partnerToken model.user) albums
          )

        Err err ->
          ( { model | errorMessage = Just (networkErrorMessage err) }
          , Effects.none
          )

    UpdatePhotoAlbum result ->
      case result of
        Ok album ->
          let
            updateAlbum new old =
              if new.photoAlbumId == old.photoAlbumId
                then new
                else old
          in
            ( { model | photoAlbums = List.map (updateAlbum album) model.photoAlbums }
            , Effects.none
            )

        Err err ->
          -- TODO: might want to associate an error with a particular album
          ( { model | errorMessage = Just (networkErrorMessage err) }
          , Effects.none
          )

    DownloadPhoto photo ->
      let
        downloads =
          Dict.insert photo.photoId 0.0 model.photoDownloads
      in
        ( { model | photoDownloads = downloads }
        , downloadPhoto photo
        )

    DownloadAlbum album ->
      let
        downloads =
          List.map (\p -> (p.photoId, 0.0)) album.photos
            |> Dict.fromList
            |> (flip Dict.union) model.photoDownloads
      in
        ( { model | photoDownloads = downloads }
        , downloadAlbum album
        )

    DownloadProgress (percentage, photo) ->
      let
        downloads =
          Dict.insert photo.photoId percentage model.photoDownloads

        fx =
          if percentage == 100.0
            then completeDownload photo
            else Effects.none
      in
        ( { model | photoDownloads = downloads }
        , fx
        )

    DownloadComplete photo ->
      let
        downloads =
          Dict.remove photo.photoId model.photoDownloads

      in
        ( { model | photoDownloads = downloads }
        , Effects.none
        )


    CancelDownload photo ->
      let
        downloads =
          Dict.remove photo.photoId model.photoDownloads
      in
        ( { model | photoDownloads = downloads }
        , Effects.none
        )


updateUser : Maybe C.User -> Model -> Model
updateUser user model =
  { model
  | user = user
  , currentAlbum = Nothing
  , photoAlbums = []
  }

{-
Side effects
-}


loadPhotoAlbums : String -> C.User -> Effects Action
loadPhotoAlbums partnerToken user =
  sendPhotoAlbumsRequest partnerToken user
    |> Task.toResult
    |> Task.map DisplayPhotoAlbums
    |> Effects.task


sendPhotoAlbumsRequest : String -> C.User -> Task Error (List PhotoAlbum)
sendPhotoAlbumsRequest partnerToken user =
  Http.fromJson photoAlbumsDecoder
    <| Http.send Http.defaultSettings
        { verb = "GET"
        , headers =
            [ ("X-Partner-Token", partnerToken)
            , ("X-User-Token", user.token)
            ]
        , url = "http://trooptrack.dev/api/v1/photo_albums"
        , body = Http.empty
        }


fetchAlbumDetails : String -> Maybe C.User -> PhotoAlbum -> Effects Action
fetchAlbumDetails partnerToken user album =
  case user of

    Nothing ->
      Task.succeed ()
        |> Task.map (always NoOp)
        |> Effects.task

    Just user ->
      sendPhotoAlbumDetailsRequest partnerToken user album
        |> Task.toResult
        |> Task.map UpdatePhotoAlbum
        |> Effects.task


sendPhotoAlbumDetailsRequest : String -> C.User -> PhotoAlbum -> Task Error PhotoAlbum
sendPhotoAlbumDetailsRequest partnerToken user album =
  Http.fromJson photoAlbumDecoder
    <| Http.send Http.defaultSettings
        { verb = "GET"
        , headers =
            [ ("X-Partner-Token", partnerToken)
            , ("X-User-Token", user.token)
            ]
        , url = "http://trooptrack.dev/api/v1/photo_albums/" ++ toString album.photoAlbumId
        , body = Http.empty
        }


downloadAlbum : PhotoAlbum -> Effects Action
downloadAlbum album =
  Signal.send albumDownloader.address album.photos
    |> Effects.task
    |> Effects.map (always NoOp)


downloadPhoto : Photo -> Effects Action
downloadPhoto photo =
  Signal.send photoDownloader.address photo
    |> Effects.task
    |> Effects.map (always NoOp)


completeDownload : Photo -> Effects Action
completeDownload photo =
  Task.sleep 1000 `Task.andThen`
    always (Task.succeed (DownloadComplete photo))
    |> Effects.task


logout : Effects Action
logout =
  Signal.send endSession.address ()
    |> Effects.task
    |> Effects.map (always NoOp)

{-
Decoders
-}


photoAlbumsDecoder : Json.Decoder (List PhotoAlbum)
photoAlbumsDecoder =
  Json.at ["photo_albums"] <| Json.list photoAlbumDecoder


photoAlbumDecoder : Json.Decoder PhotoAlbum
photoAlbumDecoder =
  Json.object5 PhotoAlbum
    ("name" := Json.string)
    ("taken_on" := Json.string)
    ("photo_count" := Json.int)
    ("photo_album_id" := Json.int)
    (Json.oneOf
      [ "troop_photos" := Json.list photoDecoder
      , Json.succeed []
      ]
    )


photoDecoder : Json.Decoder Photo
photoDecoder =
  Json.object3 Photo
    ("photo" := Json.string)
    ("troop_photo_id" := Json.int)
    (photoPathDecoder)


{-
Parse the photo url and extracts the path segments into a field.
-}
photoPathDecoder : Json.Decoder (List String)
photoPathDecoder =
  let
    parseUrl url =
      Erl.parse url
        |> .path
        |> Ok
  in
    Json.customDecoder ("photo" := Json.string) parseUrl


{-
Mailboxes
-}


photoDownloader : Signal.Mailbox Photo
photoDownloader =
  Signal.mailbox Model.emptyPhoto


albumDownloader : Signal.Mailbox (List Photo)
albumDownloader =
  Signal.mailbox []


endSession : Signal.Mailbox ()
endSession =
  Signal.mailbox ()


{-
Utility
-}


networkErrorMessage : Http.Error -> String
networkErrorMessage err =
  case err of

    Timeout ->
      "Having trouble reaching the server"

    NetworkError ->
      "You don't appear to be conencted to the network"

    UnexpectedPayload msg ->
      "Received an unexpected result from the server: " ++ msg

    BadResponse status msg ->
      "Error communicating with the server: " ++ toString status ++ " --  " ++ msg
