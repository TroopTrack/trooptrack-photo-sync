module PhotoAlbums.Model where

import Credentials as C
import Dict exposing (Dict)


type alias Model =
  { photoAlbums : List PhotoAlbum
  , user : Maybe C.User
  , currentAlbum : Maybe PhotoAlbum
  , photoDownloads : Dict Int Float
  , menuState : MenuState
  }


type alias PhotoAlbum =
  { name : String
  , takenOn : String
  , photoCount : Int
  , photoAlbumId : Int
  , photos : List Photo
  }


type alias Photo =
  { photoUrl : String
  , photoId : Int
  , path : List String
  }


type MenuState
  = MenuOn
  | MenuOff


initialModel : Model
initialModel =
  { photoAlbums = []
  , user = Nothing
  , currentAlbum = Nothing
  , photoDownloads = Dict.empty
  , menuState = MenuOff
  }


emptyPhoto : Photo
emptyPhoto =
  { photoUrl = ""
  , photoId = 0
  , path = []
  }
