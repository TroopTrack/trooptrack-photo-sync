module PhotoAlbums.Update exposing (..)

import Http exposing (Error(..))
import Json.Decode as Json exposing ((:=))
import Task exposing (Task)
import Credentials as C
import PhotoAlbums.Model as Model exposing (Model, PhotoAlbum, Photo)
import Erl
import Dict
import Process
import Ports


type Action
    = LoadPhotoAlbums C.User
    | DisplayPhotoAlbums (Result Error (List PhotoAlbum))
    | DisplayTroopSelection
    | UpdatePhotoAlbum (Result Error PhotoAlbum)
    | CurrentAlbum (Maybe PhotoAlbum)
    | DownloadPhoto Photo
    | DownloadAlbum PhotoAlbum
    | DownloadProgress ( Float, Photo )
    | DownloadComplete Photo
    | CancelDownload Photo
    | SetMenuState Model.MenuState
    | Logout
    | NoOp


update : Action -> String -> Model -> ( Model, Cmd Action )
update action partnerToken model =
    case action of
        NoOp ->
            model ! []

        Logout ->
            ( model, Ports.logout () )

        SetMenuState state ->
            { model | menuState = state } ! []

        CurrentAlbum album ->
            { model | currentAlbum = album, menuState = Model.MenuOff } ! []

        LoadPhotoAlbums user ->
            updateUser (Just user) model ! [ loadPhotoAlbums partnerToken user ]

        DisplayTroopSelection ->
            let
                newModel =
                    updateUser Nothing model
            in
                { newModel | menuState = Model.MenuOff } ! []

        DisplayPhotoAlbums result ->
            case result of
                Ok albums ->
                    { model | photoAlbums = albums }
                        ! List.map (fetchAlbumDetails partnerToken model.user) albums

                Err err ->
                    model
                        ! [ networkErrorMessage err
                                |> Ports.errorNotification
                          ]

        UpdatePhotoAlbum result ->
            case result of
                Ok album ->
                    let
                        updateAlbum new old =
                            if new.photoAlbumId == old.photoAlbumId then
                                new
                            else
                                old
                    in
                        ( { model | photoAlbums = List.map (updateAlbum album) model.photoAlbums }
                        , Cmd.none
                        )

                Err err ->
                    -- TODO: might want to associate an error with a particular album
                    ( model
                    , Ports.errorNotification <| networkErrorMessage err
                    )

        DownloadPhoto photo ->
            let
                downloads =
                    Dict.insert photo.photoId 0.0 model.photoDownloads
            in
                ( { model | photoDownloads = downloads }
                , Ports.downloadPhoto photo
                )

        DownloadAlbum album ->
            let
                downloads =
                    List.map (\p -> ( p.photoId, 0.0 )) album.photos
                        |> Dict.fromList
                        |> (flip Dict.union) model.photoDownloads
            in
                ( { model | photoDownloads = downloads }
                , Ports.downloadAlbum album
                )

        DownloadProgress ( percentage, photo ) ->
            let
                downloads =
                    Dict.insert photo.photoId percentage model.photoDownloads

                fx =
                    if percentage == 100.0 then
                        completeDownload photo
                    else
                        Cmd.none
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
                , Cmd.none
                )

        CancelDownload photo ->
            let
                downloads =
                    Dict.remove photo.photoId model.photoDownloads
            in
                ( { model | photoDownloads = downloads }
                , Cmd.none
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


loadPhotoAlbums : String -> C.User -> Cmd Action
loadPhotoAlbums partnerToken user =
    sendPhotoAlbumsRequest partnerToken user
        |> Task.toResult
        |> Task.perform DisplayPhotoAlbums DisplayPhotoAlbums


sendPhotoAlbumsRequest : String -> C.User -> Task Error (List PhotoAlbum)
sendPhotoAlbumsRequest partnerToken user =
    Http.fromJson photoAlbumsDecoder
        <| Http.send Http.defaultSettings
            { verb = "GET"
            , headers =
                [ ( "X-Partner-Token", partnerToken )
                , ( "X-User-Token", user.token )
                ]
            , url =
                "https://trooptrack.com/api/v1/photo_albums"
                --, url = "http://trooptrack.dev/api/v1/photo_albums"
            , body = Http.empty
            }


fetchAlbumDetails : String -> Maybe C.User -> PhotoAlbum -> Cmd Action
fetchAlbumDetails partnerToken user album =
    case user of
        Nothing ->
            Task.succeed ()
                |> Task.perform (always NoOp) (always NoOp)

        Just user ->
            sendPhotoAlbumDetailsRequest partnerToken user album
                |> Task.toResult
                |> Task.perform UpdatePhotoAlbum UpdatePhotoAlbum


sendPhotoAlbumDetailsRequest : String -> C.User -> PhotoAlbum -> Task Error PhotoAlbum
sendPhotoAlbumDetailsRequest partnerToken user album =
    Http.fromJson photoAlbumDecoder
        <| Http.send Http.defaultSettings
            { verb = "GET"
            , headers =
                [ ( "X-Partner-Token", partnerToken )
                , ( "X-User-Token", user.token )
                ]
            , url =
                "https://trooptrack.com/api/v1/photo_albums/" ++ toString album.photoAlbumId
                --, url = "http://trooptrack.dev/api/v1/photo_albums/" ++ toString album.photoAlbumId
            , body = Http.empty
            }


completeDownload : Photo -> Cmd Action
completeDownload photo =
    Process.sleep 1000
        `Task.andThen` always (Task.succeed (DownloadComplete photo))
        |> Task.perform identity identity



{-
   Decoders
-}


photoAlbumsDecoder : Json.Decoder (List PhotoAlbum)
photoAlbumsDecoder =
    Json.at [ "photo_albums" ] <| Json.list photoAlbumDecoder


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
    Json.object4 Photo
        ("photo" := Json.string)
        ("thumb" := Json.string)
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
   Utility
-}


networkErrorMessage : Http.Error -> String
networkErrorMessage err =
    case err of
        Timeout ->
            "Having trouble reaching the server"

        NetworkError ->
            "You don't appear to be connected to the network"

        UnexpectedPayload msg ->
            "Received an unexpected result from the server: " ++ msg

        BadResponse status msg ->
            "Error communicating with the server: " ++ toString status ++ " --  " ++ msg
