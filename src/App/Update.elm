module App.Update exposing (..)

import App.Model as Model
import Login.Update as Login
import PhotoAlbums.Update
import Credentials as C
import Notifications
import Releases
import Pages
import Task
import Ports


type Action
    = Authentication Login.Action
    | PhotoAlbums PhotoAlbums.Update.Action
    | NoOp
    | CurrentUser (Maybe C.Credentials)
    | ResetSession
    | Notify Notifications.Notification
    | LatestRelease (Maybe Releases.Release)


init : Model.Flags -> ( Model.Model, Cmd Action )
init flags =
    let
        impl =
            ( Model.initialModel flags.partnerToken flags.version
            , Cmd.batch
                [ Ports.getCurrentUser ()
                , findLatestRelease
                ]
            )
    in
        impl


update : Action -> Model.Model -> ( Model.Model, Cmd Action )
update action model =
    case action of
        NoOp ->
            ( model, Cmd.none )

        LatestRelease maybeRelease ->
            let
                updateTarget =
                    Releases.needsUpdate model.version maybeRelease

                baseMessage =
                    """
          A new version of TroopTrack Photo Sync is available.
          You can download it here:
          """

                updateLink release =
                    "<a href='" ++ release.url ++ "' taget='_blank'>" ++ release.version ++ "</a>"

                updateMessage release =
                    baseMessage ++ updateLink release

                updateFx release =
                    updateMessage release
                        |> Notifications.info
                        |> Ports.notifications
            in
                case updateTarget of
                    Nothing ->
                        ( model, Cmd.none )

                    Just release ->
                        ( model, updateFx release )

        Notify notification ->
            ( model
            , Ports.notifications notification
            )

        ResetSession ->
            let
                token =
                    model.loginInfo.credentials.partnerToken

                version =
                    model.version.version
            in
                ( Model.initialModel token version
                , Ports.getCurrentUser ()
                )

        CurrentUser maybeCreds ->
            case maybeCreds of
                Nothing ->
                    let
                        loginInfo =
                            model.loginInfo

                        creds =
                            loginInfo.credentials

                        newCreds =
                            { creds | users = [] }

                        newLoginInfo =
                            { loginInfo | credentials = newCreds }
                    in
                        ( { model
                            | page = Pages.LoginPage
                            , loginInfo = newLoginInfo
                          }
                        , Cmd.none
                        )

                Just creds ->
                    let
                        loginInfo =
                            model.loginInfo

                        newLoginInfo =
                            { loginInfo | credentials = creds }
                    in
                        ( { model
                            | loginInfo = newLoginInfo
                            , page = Pages.PhotoAlbumsPage
                          }
                        , Cmd.none
                        )

        Authentication creds ->
            let
                ( login, fx ) =
                    Login.update creds model.loginInfo

                users =
                    login.credentials.users

                page =
                    if List.isEmpty users then
                        model.page
                    else
                        Pages.PhotoAlbumsPage
            in
                ( { model | loginInfo = login, page = page }
                , Cmd.map Authentication fx
                )

        PhotoAlbums photoAlbumAct ->
            let
                credentials =
                    model.loginInfo.credentials

                ( newPhotoAlbums, fx ) =
                    PhotoAlbums.Update.update photoAlbumAct credentials.partnerToken model.photoAlbums
            in
                ( { model | photoAlbums = newPhotoAlbums }
                , Cmd.map PhotoAlbums fx
                )



--- Cmd


findLatestRelease : Cmd Action
findLatestRelease =
    Releases.latestVersion
        |> Task.toMaybe
        |> Task.perform LatestRelease LatestRelease
