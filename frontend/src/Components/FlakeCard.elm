module Components.FlakeCard exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Octicons
import Route.Path


type alias FlakeCard =
    { username : String
    , repo : String
    , version : String
    , description : String
    }


view : FlakeCard -> Html msg
view card =
    div [ class "mx-auto max-w-3xl text-lg block bg-white w-full h-28 px-8 py-6 rounded-md shadow-sm border border-slate-150" ]
        [ div [ class "flex items-center" ]
            [ Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.class "inline" |> Octicons.markGithub
            , a [ Route.Path.href (Route.Path.Flake_Github_Org_ { org = card.username }), class "ml-2 hover:text-sky-500" ] [ span [ class "font-semibold" ] [ text card.username ] ]
            , span [ class "mx-2" ] [ text "/" ]
            , a [ Route.Path.href (Route.Path.Flake_Github_Org__Repo_ { org = card.username, repo = card.repo }), class "hover:text-sky-500" ] [ span [ class "font-semibold" ] [ text card.repo ] ]
            , span [ class "ml-3 mr-1" ] [ Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.class "inline" |> Octicons.tag ]
            , a [ Route.Path.href (Route.Path.Flake_Github_Org__Repo__Version_ { org = card.username, repo = card.repo, version = card.version }), class "hover:text-sky-500" ] [ span [ class "font-semibold" ] [ text card.version ] ]
            ]
        , p [ class "mt-2" ] [ text card.description ]
        ]
