module PhotoAlbums.Model where

import Credentials as C
import Dict exposing (Dict)


type alias Model =
  { photoAlbums : List PhotoAlbum
  , errorMessage : Maybe String
  , user : Maybe C.User
  , currentAlbum : Maybe PhotoAlbum
  , photoDownloads : Dict Int Float
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


initialModel : Model
initialModel =
  { photoAlbums = []
  , errorMessage = Nothing
  , user = Nothing
  , currentAlbum = Nothing
  , photoDownloads = Dict.empty
  }


emptyPhoto : Photo
emptyPhoto =
  { photoUrl = ""
  , photoId = 0
  , path = []
  }
