module App.Model where

import Login.Model as Login
import PhotoAlbums.Model as PhotoAlbums

type alias Model =
  { page : Page
  , loginInfo : Login.Model
  , photoAlbums : PhotoAlbums.Model
  }

type Page
  = LoginPage
  | PhotoAlbumsPage
  | LoadingPage


initialModel : Model
initialModel =
  { page = LoadingPage
  , loginInfo = Login.initialModel
  , photoAlbums = PhotoAlbums.initialModel
  }
