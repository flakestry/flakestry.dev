module Pages.Home_ exposing (page)

import Html exposing (..)
import Html.Attributes exposing (..)
import Svg
import Svg.Attributes as SvgAttr
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
                            , button [ class "bg-blue-950 text-white py-1 px-4 rounded hover:bg-blue-600" ]
                                [ Svg.svg
                                    [ SvgAttr.fill "none"
                                    , SvgAttr.viewBox "0 0 24 24"
                                    , SvgAttr.strokeWidth "1.5"
                                    , SvgAttr.stroke "currentColor"
                                    , SvgAttr.class "w-5 h-5"
                                    ]
                                    [ Svg.path
                                        [ SvgAttr.strokeLinecap "round"
                                        , SvgAttr.strokeLinejoin "round"
                                        , SvgAttr.d "M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5m-13.5-9L12 3m0 0l4.5 4.5M12 3v13.5"
                                        ]
                                        []
                                    ]
                                , text "Publish"
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        , {- Content -}
          main_
            [ class "container w-auto bg-slate-50 p-24 h-full"
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
