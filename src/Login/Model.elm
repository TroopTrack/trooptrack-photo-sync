module Login.Model where

import Credentials as C

type alias Model =
  { username : String
  , password : String
  , authenticating : Bool
  , credentials : C.Credentials
  , errorMessage : Maybe String
  , successMessage : Maybe String
  }


initialModel : Model
initialModel =
  { username = ""
  , password = ""
  , authenticating = False
  , credentials = C.initialCredentials
  , errorMessage = Nothing
  , successMessage = Nothing
  }
