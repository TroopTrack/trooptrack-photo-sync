module Credentials exposing (..)

import Dict


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
    , troop_type_id : Int
    , user_id : Int
    }


type TroopType
    = BsaTroop
    | GsaTroop
    | TlTroop
    | AhgTroop
    | BsaCubs
    | BsaClub
    | BsaCrew
    | AuPack
    | BadenPowell
    | NzGrp
    | BsaTeam
    | Cap
    | SeaScouts
    | UnknownTroopType


type alias TroopTypes =
    Dict.Dict Int TroopType


initialCredentials : String -> Credentials
initialCredentials partnerToken =
    --{ partnerToken = "l3CrVXqaUxS0Gb-cNcEBuA"
    { partnerToken = partnerToken
    , users = []
    }


initializeTroopTypes : TroopTypes
initializeTroopTypes =
    let
        typesList =
            [ ( 1, BsaTroop )
            , ( 5, GsaTroop )
            , ( 6, AhgTroop )
            , ( 3, BsaCubs )
            , ( 7, BsaClub )
            , ( 9, BsaCrew )
            , ( 10, AuPack )
            , ( 12, TlTroop )
            , ( 8, BadenPowell )
            , ( 13, NzGrp )
            , ( 14, BsaTeam )
            , ( 15, Cap )
            , ( 17, SeaScouts )
            ]
    in
        Dict.fromList typesList
