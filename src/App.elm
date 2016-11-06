module App exposing (..)

import Html.App
import App.View as View
import App.Update as Update
import App.Model as Model
import PhotoAlbums.Update
import Ports
import Notifications


main : Program Model.Flags
main =
    Html.App.programWithFlags
        { init = Update.init
        , update = Update.update
        , view = View.view
        , subscriptions = subscriptions
        }


subscriptions : Model.Model -> Sub Update.Action
subscriptions model =
    Sub.batch
        [ Ports.setCurrentUser Update.CurrentUser
        , Ports.sessionEnded Update.CurrentUser
        , Ports.downloadProgress (Update.PhotoAlbums << PhotoAlbums.Update.DownloadProgress)
        , Ports.cancelledDownloads (Update.PhotoAlbums << PhotoAlbums.Update.CancelDownload)
        , Ports.errorNotifications (Update.Notify << Notifications.error)
        ]
