module PhotoAlbums.View where


import Signal exposing (Address)

import Html as H exposing (Html, Attribute)
import Html.Attributes as A


import Credentials as C
import PhotoAlbums.Update as Update
import PhotoAlbums.Model as Model exposing (Model, PhotoAlbum, Photo)


import PhotoAlbums.View.Menu exposing (menu, mask)
import PhotoAlbums.View.Topbar exposing (topbar)
import PhotoAlbums.View.Gallery exposing (content)


view : Address Update.Action -> C.TroopTypes -> C.Credentials -> Model -> Html
view address troopTypes credentials model =
 H.div
  []
  [ topbar address model
  , H.div
    [ A.class "content" ]
    [ content address troopTypes credentials model
    ]
  , menu address model
  , mask model
  ]
