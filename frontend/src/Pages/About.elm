module Pages.About exposing (..)

import Flakestry.Layout
import Html exposing (..)
import Html.Attributes exposing (..)
import View exposing (View)


about : String
about =
    """
  Flakestry is [an open source project](https://github.com/flakestry/flakestry.dev)
  with the goal of making it easier to publish and discover Flakes.

  It is intended as a replacement for the existing [search.nixos.org/flakes](https://search.nixos.org/flakes).
  We are fully committed to making Flakestry an official Nix project.

  Currently it's possible to publish flakes via [GitHub actions](/publish), but [other sources could be added](https://github.com/flakestry/flakestry.dev/issues/1) later on.

  As flakes stabilize, we hope to see more and more flakes being published to the registry.

  As flakes evolve, we hope to see better [introspection of the outputs](https://github.com/flakestry/flakestry.dev/issues/2) for each release and upstreaming of
  important features as [flake versioning](https://github.com/NixOS/rfcs/pull/144) and dependency resolution.
"""


page : View msg
page =
    { title = "flakestry - About"
    , body =
        Flakestry.Layout.viewBody
            [ Flakestry.Layout.viewNav
            , main_ []
                [ Html.node "highlight-code"
                    [ class "container px-4 py-24 max-w-3xl prose"
                    , attribute "code" about
                    , attribute "language" "markdown"
                    ]
                    []
                ]
            , Flakestry.Layout.viewFooter
            ]
    }
