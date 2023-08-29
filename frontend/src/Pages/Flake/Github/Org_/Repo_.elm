module Pages.Flake.Github.Org_.Repo_ exposing (Model, Msg, page)

import Effect exposing (Effect)
import Flakestry.Layout
import Html exposing (..)
import Html.Attributes exposing (..)
import Markdown
import Octicons
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View exposing (View)


page : Shared.Model -> Route { org : String, repo : String } -> Page Model Msg
page shared route =
    Page.new
        { init = init route
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { org : String
    , repo : String
    , description : String
    , renderedReadme : String
    }


init : Route { org : String, repo : String } -> () -> ( Model, Effect Msg )
init route _ =
    ( { org = route.params.org
      , repo = route.params.repo
      , description = "A short and punchy description of the project"
      , renderedReadme = fakeReadme
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = ExampleMsgReplaceMe


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ExampleMsgReplaceMe ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Flake " ++ model.org ++ "/" ++ model.repo
    , body =
        [ Flakestry.Layout.viewNav
        , div [ class "container max-w-5xl px-4" ]
            [ h2 [ class "flex items-center font-semibold text-2xl leading-6 mt-6" ]
                [ img [ class "inline h-7 w-7 rounded border border-slate-300", src ("https://github.com/" ++ model.org ++ ".png?size=128") ] []
                , span [ class "ml-2" ] [ text <| model.org ++ " / " ++ model.repo ]
                ]
            , p [ class "mt-3 text-lg leading-6" ] [ text "Some detailed description of the repo" ]
            , h3 [ class "font-semibold flex items-center mt-24 py-4" ]
                [ Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.class "inline h-5 w-5" |> Octicons.book
                , span [ class "ml-2" ] [ text "README" ]
                ]
            , pre [] [ Markdown.toHtml [ class "content whitespace-pre-wrap rounded-md px-8 py-12 shadow-sm border border-slate-300" ] model.renderedReadme ]
            ]
        , Flakestry.Layout.viewFooter
        ]
    }


fakeReadme : String
fakeReadme =
    """
# devenv.sh - Fast, Declarative, Reproducible, and Composable Developer Environments

[![Built with Nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)
[![Discord channel](https://img.shields.io/discord/1036369714731036712?color=7389D8&label=discord&logo=discord&logoColor=ffffff)](https://discord.gg/naMgvexb6q)
![License: Apache 2.0](https://img.shields.io/github/license/cachix/devenv)
[![Version](https://img.shields.io/github/v/release/cachix/devenv?color=green&label=version&sort=semver)](https://github.com/cachix/devenv/releases)
[![CI](https://github.com/cachix/devenv/actions/workflows/buildtest.yml/badge.svg)](https://github.com/cachix/devenv/actions/workflows/buildtest.yml?branch=main)

![logo](docs/assets/logo.webp)

Running ``devenv init`` generates ``devenv.nix``:

```nix
{ pkgs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [ pkgs.git ];

  enterShell = ''
    hello
    git --version
  '';

  # https://devenv.sh/languages/
  languages.nix.enable = true;

  # https://devenv.sh/scripts/
  scripts.hello.exec = "echo hello from $GREET";

  # https://devenv.sh/pre-commit-hooks/
  pre-commit.hooks.shellcheck.enable = true;

  # https://devenv.sh/processes/
  # processes.ping.exec = "ping example.com";
}

```

And ``devenv shell`` activates the environment.

## Commands

- ``devenv init``:           Scaffold devenv.yaml, devenv.nix, and .envrc.
- ``devenv shell``:          Activate the developer environment.
- ``devenv shell CMD ARGS``: Run CMD with ARGS in the developer environment.
- ``devenv update``:         Update devenv.lock from devenv.yaml inputs. See http://devenv.sh/inputs/#locking-and-updating-inputs.
- ``devenv up``:             Start processes in foreground. See http://devenv.sh/processes.
- ``devenv gc``:             Remove old devenv generations. See http://devenv.sh/garbage-collection.
- ``devenv ci``:             Build your developer environment and make sure all checks pass.

## Documentation

- [Getting Started](https://devenv.sh/getting-started/)
- [Basics](https://devenv.sh/basics/)
- [Roadmap](https://devenv.sh/roadmap/)
- [Blog](https://devenv.sh/blog/)
- [`devenv.yaml` reference](https://devenv.sh/reference/yaml-options/)
- [`devenv.nix` reference](https://devenv.sh/reference/options/)
- [Contributing](https://devenv.sh/community/contributing/)
             """
