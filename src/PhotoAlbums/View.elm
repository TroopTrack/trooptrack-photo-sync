module PhotoAlbums.View exposing (..)

import Html as H exposing (Html, Attribute)
import Html.Attributes as A
import Credentials as C
import PhotoAlbums.Update as Update
import PhotoAlbums.Model as Model exposing (Model, PhotoAlbum, Photo)
import PhotoAlbums.View.Menu exposing (menu, mask)
import PhotoAlbums.View.Topbar exposing (topbar)
import PhotoAlbums.View.Gallery exposing (content)


view : C.TroopTypes -> C.Credentials -> Model -> Html Update.Action
view troopTypes credentials model =
    H.div []
        [ topbar model
        , H.div [ A.class "content" ]
            [ content troopTypes credentials model
            ]
        , menu model
        , mask model
        ]
