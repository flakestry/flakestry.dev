module Flakestry.Layout exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Svg
import Svg.Attributes as SvgAttr


viewNav : Html msg
viewNav =
    nav
        [ class "py-4"
        ]
        [ div
            [ class "container max-w-5xl"
            ]
            [ div
                [ class "flex justify-between items-center"
                ]
                [ div [ class "flex space-x-2" ]
                    [ img [ src "/logo.png", class "w-7" ] []
                    , a
                        [ href "/"
                        , class "text-xl font-bold tracking-tight"
                        ]
                        [ text "Flakestry" ]
                    ]
                , div [ class "flex" ]
                    [ ul
                        [ class "flex items-center space-x-10 mr-10 text-sm leading-6 font-medium text-slate-800"
                        ]
                        [ li [ class "hover:text-sky-500" ]
                            [ a
                                [ href "/about" ]
                                [ text "About" ]
                            ]
                        ]
                    , div [ class "flex items-center space-x-2" ]
                        [ a [ class "bg-blue-900 text-white text-sm font-medium pl-2 pr-3 py-2 cursor-pointer shadow-sm rounded hover:bg-blue-600 inline-flex items-center", href "/publish" ]
                            [ Svg.svg
                                [ SvgAttr.fill "currentColor"
                                , SvgAttr.viewBox "0 0 20 20"
                                , SvgAttr.class "w-4 h-4 mr-2"
                                ]
                                [ Svg.path
                                    [ SvgAttr.d "M9.25 13.25a.75.75 0 001.5 0V4.636l2.955 3.129a.75.75 0 001.09-1.03l-4.25-4.5a.75.75 0 00-1.09 0l-4.25 4.5a.75.75 0 101.09 1.03L9.25 4.636v8.614z"
                                    ]
                                    []
                                , Svg.path
                                    [ SvgAttr.d "M3.5 12.75a.75.75 0 00-1.5 0v2.5A2.75 2.75 0 004.75 18h10.5A2.75 2.75 0 0018 15.25v-2.5a.75.75 0 00-1.5 0v2.5c0 .69-.56 1.25-1.25 1.25H4.75c-.69 0-1.25-.56-1.25-1.25v-2.5z"
                                    ]
                                    []
                                ]
                            , span [] [ text "Publish" ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


viewFooter : Html msg
viewFooter =
    footer
        [ class "text-sm pb-16 leading-6"
        ]
        [ div
            [ class "container max-w-5xl border-t border-slate-300 pt-8"
            ]
            [ div [ class "flex-none w-1/2 space-y-10 sm:space-y-8" ]
                [ h2 [ class "font-medium" ] [ text "Getting Started" ]
                , ul [ class "mt-3 space-y-2" ]
                    [ li [] [ a [ href "https://nix.dev/concepts/flakes#flakes" ] [ text "What are Flakes?" ] ]
                    ]
                ]
            ]
        ]
