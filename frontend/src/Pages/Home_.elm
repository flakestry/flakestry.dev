module Pages.Home_ exposing (page)

import Html exposing (..)
import Html.Attributes exposing (..)
import View exposing (View)


page : View msg
page =
    { title = "flakestry"
    , body =
        [ nav
            [ class "text-black p-4"
            ]
            [ div
                [ class "container mx-auto"
                ]
                [ div
                    [ class "flex justify-between items-center"
                    ]
                    [ div [ class "flex space-x-4" ]
                        [ img [ src "https://raw.githubusercontent.com/NixOS/nixos-artwork/master/logo/nix-snowflake.svg", class "w-8" ] []
                        , a
                            [ href "/"
                            , class "text-2xl font-bold"
                            ]
                            [ text "Flakestry" ]
                        ]
                    , ul
                        [ class "flex space-x-4"
                        ]
                        [ li []
                            [ a
                                [ href "#"
                                , class "hover:underline"
                                ]
                                [ text "About" ]
                            ]
                        , div [ class "flex items-center space-x-2" ]
                            [ input [ class "py-1 px-2 mx-8 rounded", placeholder "Search", type_ "text" ]
                                []
                            , button [ class "bg-blue-500 text-white py-1 px-4 rounded hover:bg-blue-600" ]
                                [ text "Publish" ]
                            ]
                        ]
                    ]
                ]
            ]
        , {- Content -}
          main_
            [ class "container w-auto bg-slate-50 p-24 h-full flex-1"
            ]
            [ h1
                [ class "text-3xl font-semibold mb-4"
                ]
                [ text "Welcome to flakestry!" ]
            , p []
                [ text "Here goes flakes ..." ]
            ]
        , {- Footer -}
          footer
            [ class "bg-blue-950 text-white p-4"
            ]
            [ div
                [ class "container mx-auto text-center"
                ]
                [ p []
                    [ text "Read more about this project <here>." ]
                ]
            ]
        ]
    }
