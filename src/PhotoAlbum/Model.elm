module PhotoAlbum.Model where

import Credentials as C

type alias Model =
  { photoAlbums : List PhotoAlbum
  , errorMessage : Maybe String
  , user : Maybe C.User
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
  }

initialModel : Model
initialModel =
  { photoAlbums = []
  , errorMessage = Nothing
  , user = Nothing
  }
