module Pages.About exposing (..)

import Flakestry.Layout
import Html exposing (..)
import Html.Attributes exposing (..)
import Markdown
import View exposing (View)


about : String
about =
    """
  Flakestry is [a open source Nix community project](https://github.com/flakestry/flakestry.dev)
  with the goal to replace the existing [search.nixos.org/flakes](https://search.nixos.org/flakes) by making it easier to
  release flakes.

  Currently it's possible to publish flakes via [GitHub actions](/publish), but [other sources could be added](https://github.com/flakestry/flakestry.dev/issues/1) later on.

  As flakes stabilize, we hope to see more and more flakes being published to the registry.

  As flakes evolve, we hope to see better [introspection of the outputs](https://github.com/flakestry/flakestry.dev/issues/2) for each release and upstreaming of
  important features as [flake versioning](https://github.com/NixOS/rfcs/pull/144) and dependency resolution.
"""


page : View msg
page =
    { title = "flakestry - Publish"
    , body =
        Flakestry.Layout.viewBody
            [ Flakestry.Layout.viewNav
            , main_ [] [ Markdown.toHtml [ class "container px-4 py-24 max-w-3xl prose" ] about ]
            , Flakestry.Layout.viewFooter
            ]
    }
