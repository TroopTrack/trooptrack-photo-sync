module App.Model where

import Login.Model as Login
import PhotoAlbums.Model as PhotoAlbums
import Pages
import Credentials as C


type alias Model =
  { page : Pages.Page
  , loginInfo : Login.Model
  , photoAlbums : PhotoAlbums.Model
  , troopTypes : C.TroopTypes
  }


initialModel : String -> Model
initialModel partnerToken =
  { page = Pages.LoadingPage
  , loginInfo = Login.initialModel partnerToken
  , photoAlbums = PhotoAlbums.initialModel
  , troopTypes = C.initializeTroopTypes
  }
