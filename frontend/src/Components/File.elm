module Components.File exposing (..)

import Html exposing (..)
import Html.Attributes as HA
import Octicons


{-| Options to configure how the file is rendered.

  - `fileName` - The name of the file. This is displayed in the header.

  - `contents` - The contents of the file.

  - `class` - Extra classes to add to the file.

  - `language` - The language of the file. The default is "markdown". Markdown
    is rendered with marked. For other languages, the contents are highlighted
    with highlight.js.

  - `copyableContents` - Whether to enable the copy button and what to copy into the clipboard.

  - `baseUrl` - The base URL to use when rewriting any relative URLS in the file.

  - `rawBaseUrl` - The base URL to use when rewriting any image URLS in the file.

-}
type alias Options =
    { fileName : String
    , contents : String
    , class_ : String
    , language : String
    , copyableContents : Maybe String
    , baseUrl : String
    , rawBaseUrl : String
    }


defaultOptions : Options
defaultOptions =
    { fileName = ""
    , contents = ""
    , class_ = ""
    , language = "markdown"
    , copyableContents = Nothing
    , baseUrl = ""
    , rawBaseUrl = ""
    }


fileName : String -> Options -> Options
fileName value options =
    { options | fileName = value }


contents : String -> Options -> Options
contents value options =
    { options | contents = value }


class : String -> Options -> Options
class value options =
    { options | class_ = value }


language : String -> Options -> Options
language value options =
    { options | language = value }


baseUrl : String -> Options -> Options
baseUrl value options =
    { options | baseUrl = value }


rawBaseUrl : String -> Options -> Options
rawBaseUrl value options =
    { options | rawBaseUrl = value }


setCopyableContents : Maybe String -> Options -> Options
setCopyableContents value options =
    { options | copyableContents = value }


view : Options -> Html msg
view options =
    div
        [ HA.class "border border-slate-300 rounded-md shadow-sm overflow-hidden" ]
        [ div [ HA.class "flex items-center justify-between px-4 py-2 border-b border-slate-300 bg-slate-100" ] <|
            h3
                [ HA.class "inline-flex items-center text-slate-800 font-medium py-2"
                ]
                [ Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.size 16 |> Octicons.class "inline shrink-0" |> Octicons.file
                , span [ HA.class "ml-2" ] [ text options.fileName ]
                ]
                :: (options.copyableContents
                        |> Maybe.map
                            (\copyableContents ->
                                [ viewCopyButton copyableContents ]
                            )
                        |> Maybe.withDefault []
                   )
        , file options
        ]


viewCopyButton : String -> Html msg
viewCopyButton copyableContents =
    button
        [ HA.class "ml-2 clipboard inline-flex items-center text-sm text-white font-medium pl-2 pr-3 py-2 shadow-sm rounded bg-blue-900 hover:bg-blue-600"
        , HA.type_ "button"
        , HA.attribute "data-clipboard-text" copyableContents
        ]
        [ Octicons.defaultOptions
            |> Octicons.color "currentColor"
            |> Octicons.size 15
            |> Octicons.class "inline"
            |> Octicons.clippy
        , span [ HA.class "ml-2" ] [ text "Copy" ]
        ]


file : Options -> Html msg
file options =
    Html.node "highlight-code"
        [ HA.class <| String.join " " [ "px-8 py-8 overflow-x-auto", options.class_ ]
        , HA.attribute "code" options.contents
        , HA.attribute "language" options.language
        , HA.attribute "baseUrl" options.baseUrl
        , HA.attribute "rawBaseUrl" options.rawBaseUrl
        ]
        []
