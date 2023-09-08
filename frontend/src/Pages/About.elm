module Pages.About exposing (..)

import Flakestry.Layout
import Html exposing (..)
import Html.Attributes exposing (..)
import View exposing (View)


page : View msg
page =
    { title = "flakestry - Publish"
    , body =
        Flakestry.Layout.viewBody
            [ Flakestry.Layout.viewNav
            , main_ [] []
            , Flakestry.Layout.viewFooter
            ]
    }
