module Login.Model exposing (..)

import Credentials as C


type alias Model =
    { username : String
    , password : String
    , authenticating : Bool
    , credentials : C.Credentials
    , errorMessage : Maybe String
    , successMessage : Maybe String
    }


initialModel : String -> Model
initialModel partnerToken =
    { username = ""
    , password = ""
    , authenticating = False
    , credentials = C.initialCredentials partnerToken
    , errorMessage = Nothing
    , successMessage = Nothing
    }
