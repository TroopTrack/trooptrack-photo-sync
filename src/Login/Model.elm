module Login.Model where

type alias Model =
  { username : String
  , password : String
  , authenticating : Bool
  , credentials : Credentials
  , errorMessage : Maybe String
  , successMessage : Maybe String
  }

type alias Credentials =
  { partnerToken : String
  , users : List User
  }

type alias User =
  { token : String
  , privileges : List String
  , troop : String
  , troop_id : Int
  , troop_number : String
  , troop_type : String
  , troop_type_id: Int
  , user_id : Int
  }

initialModel : Model
initialModel =
  { username = ""
  , password = ""
  , authenticating = False
  , credentials = initialCredentials
  , errorMessage = Nothing
  , successMessage = Nothing
  }

initialCredentials : Credentials
initialCredentials =
  { partnerToken = "8pOsq6XbBVtcV_0Uy49EHA"
  , users = []
  }
