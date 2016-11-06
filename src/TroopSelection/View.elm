module TroopSelection.View exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Dict
import Credentials as C
import TroopSelection.Update as Update


view : Signal.Address Update.Action -> C.TroopTypes -> C.Credentials -> H.Html
view address troopTypes credentials =
    H.div [ A.id "troop-selection" ]
        [ H.div [ A.class "gallery-items" ]
            <| List.map (galleryItem address troopTypes) credentials.users
        ]


galleryItem : Signal.Address Update.Action -> C.TroopTypes -> C.User -> H.Html
galleryItem address troopTypes user =
    H.div [ A.class "gallery-item" ]
        [ H.a
            [ E.onClick address <| Update.TroopSelected user
            , A.href "#"
            ]
            [ H.text user.troop ]
        , H.div []
            [ H.a
                [ E.onClick address <| Update.TroopSelected user
                , A.href "#"
                ]
                [ galleryImage troopTypes user ]
            ]
        ]


galleryImage : C.TroopTypes -> C.User -> H.Html
galleryImage troopTypes user =
    let
        troopType =
            Dict.get user.troop_type_id troopTypes
                |> Maybe.withDefault C.UnknownTroopType
    in
        case troopType of
            C.BsaTroop ->
                H.img [ A.src "img/bsa_share.png" ] []

            C.GsaTroop ->
                H.img [ A.src "img/gsa_share.png" ] []

            C.AhgTroop ->
                H.img [ A.src "img/ahg_share.png" ] []

            C.BsaCubs ->
                H.img [ A.src "img/cub_share" ] []

            C.BsaClub ->
                H.img [ A.src "img/bsa_share.png" ] []

            C.BsaCrew ->
                H.img [ A.src "img/bsa_share.png" ] []

            C.AuPack ->
                H.img [ A.src "img/bsa_share.png" ] []

            C.TlTroop ->
                H.img [ A.src "img/fbb_share.png" ] []

            C.BadenPowell ->
                H.img [ A.src "img/bsa_share.png" ] []

            C.NzGrp ->
                H.img [ A.src "img/bsa_share.png" ] []

            C.BsaTeam ->
                H.img [ A.src "img/bsa_share.png" ] []

            C.Cap ->
                H.img [ A.src "img/cap_share.png" ] []

            C.SeaScouts ->
                H.img [ A.src "img/ship_share.png" ] []

            C.UnknownTroopType ->
                H.img [ A.src "img/bsa_share.png" ] []
