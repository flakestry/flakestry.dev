module Flakestry.Layout exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Octicons


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
                            [ Octicons.defaultOptions |> Octicons.class "text-white mr-2" |> Octicons.color "white" |> Octicons.markGithub
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
        [ class "text-sm pb-16 mt-16 leading-6"
        ]
        [ div
            [ class "container max-w-5xl"
            ]
            [ hr [ class "flex border-t border-slate-200" ] []
            , div [ class "flex pt-12" ]
                [ div [ class "flex-none w-1/2 space-y-10 sm:space-y-8" ]
                    [ h2 [ class "font-medium" ] [ text "Getting Started" ]
                    , ul [ class "mt-3 space-y-2" ]
                        [ li [] [ a [ href "https://nix.dev/concepts/flakes#flakes", class "hover:text-blue-500" ] [ text "What are Flakes?" ] ]
                        ]
                    ]
                , div [ class "flex-none w-1/2 space-y-10 sm:space-y-8" ]
                    [ h2 [ class "font-medium" ] [ text "Resources" ]
                    , a [ href "https://github.com/flakestry/flakestry.dev", class "flex items-center hover:text-blue-500 hover:fill-blue-500" ]
                        [ Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.class "inline mr-2" |> Octicons.markGithub
                        , span [] [ text "Source Code" ]
                        ]
                    ]
                ]
            ]
        ]
