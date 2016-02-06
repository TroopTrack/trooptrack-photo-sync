module App.Model where

import Login.Model as Login
import PhotoAlbums.Model as PhotoAlbums
import Pages
import Credentials as C
import Releases


type alias Model =
  { page : Pages.Page
  , loginInfo : Login.Model
  , photoAlbums : PhotoAlbums.Model
  , troopTypes : C.TroopTypes
  , version : Releases.Release
  }


initialModel : String -> String -> Model
initialModel partnerToken version =
  { page = Pages.LoadingPage
  , loginInfo = Login.initialModel partnerToken
  , photoAlbums = PhotoAlbums.initialModel
  , troopTypes = C.initializeTroopTypes
  , version = Releases.release version
  }
