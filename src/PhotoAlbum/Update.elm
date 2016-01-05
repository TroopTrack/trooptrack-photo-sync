module PhotoAlbum.Update where

import Http exposing (Error(..))
import Json.Decode as Json exposing ((:=))

import Credentials as C
import Effects exposing (Effects)
import Task exposing (Task)

import PhotoAlbum.Model exposing (Model, PhotoAlbum, Photo)

import Debug

type Action
  = LoadPhotoAlbums C.User
  | DisplayPhotoAlbums (Result Error (List PhotoAlbum))
  | UpdatePhotoAlbum (Result Error PhotoAlbum)
  | NoOp

update : Action -> String -> Model -> (Model, Effects Action)
update action partnerToken model =
  case action of

    NoOp ->
      (model, Effects.none)

    LoadPhotoAlbums user ->
      ( { model | user = Just user }
      , loadPhotoAlbums partnerToken user)

    DisplayPhotoAlbums result ->
      case result of
        Ok albums ->
          ( { model | photoAlbums = albums
                    , errorMessage = Nothing
            }
          , Effects.batch
              <| List.map (fetchAlbumDetails partnerToken model.user) albums
          )

        Err err ->
          ( { model | errorMessage = Just (networkErrorMessage err) }
          , Effects.none )

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

-- Decoders

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
  Json.object2 Photo
    ("photo" := Json.string)
    ("troop_photo_id" := Json.int)

-- Utility

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
