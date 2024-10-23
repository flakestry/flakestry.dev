module Pages.Flake.Github.Org_.Repo_.Version_ exposing
    ( Model
    , Msg
    , init
    , page
    , subscriptions
    , update
    , view
    )

import Api
import Api.Data as Api
import Api.Request.Api as Api
import Api.Time as ApiTime
import Components.File as File
import Dict
import Dropdown
import Effect exposing (Effect)
import Flakestry.FlakeSchema
import Flakestry.Layout
import Flakestry.MetadataSchema
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode
import Octicons
import Page exposing (Page)
import RemoteData exposing (WebData)
import Route exposing (Route)
import Route.Path
import Shared
import Svg exposing (svg)
import Svg.Attributes as SvgAttr
import View exposing (View)


page : Shared.Model -> Route { org : String, repo : String, version : String } -> Page Model Msg
page _ route =
    Page.new
        { init = init route.params.org route.params.repo (Just route.params.version) route.hash
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type alias Model =
    { repoResponse : WebData Api.GetRepoResponse
    , releaseResponse : WebData Api.Release
    , org : String
    , repo : String
    , route : Route.Path.Path
    , hash : Maybe String
    , selectedOutput :
        Maybe
            { section : String
            , attribute : String
            , output : Flakestry.FlakeSchema.Output
            , systems : List String
            }

    -- global for the whole flake
    , system : String
    , expandSections : List String
    , searchQuery : Maybe String
    , versionDropdownIsOpen : Bool
    , version : Maybe String
    }


init : String -> String -> Maybe String -> Maybe String -> () -> ( Model, Effect Msg )
init org repo version hash _ =
    ( { repoResponse = RemoteData.NotAsked
      , versionDropdownIsOpen = False
      , version = version
      , org = org
      , selectedOutput = Nothing
      , route = thisRoute { org = org, repo = repo, version = version }
      , hash = hash
      , expandSections = []

      -- TODO: this should pick a sane default if x86_64-linux is not available
      , system = "x86_64-linux"
      , repo = repo
      , searchQuery = Nothing
      , releaseResponse = RemoteData.NotAsked
      }
    , Effect.sendCmd <|
        Api.send HandleGetRepoResponse <|
            Api.getRepo org repo
    )



-- UPDATE


type Msg
    = HandleGetRepoResponse (Result Http.Error Api.GetRepoResponse)
    | HandleGetVersionResponse (Result Http.Error Api.Release)
    | ToggleVersionDropdown Bool
    | SearchInput String
    | ChangeTab String
    | SelectOutput String String Flakestry.FlakeSchema.Output (List String)
    | SelectSystem String
    | ExpandSection String


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        HandleGetRepoResponse response ->
            let
                data =
                    RemoteData.fromResult response

                maybeVersion =
                    case ( model.version, data ) of
                        ( Just version, _ ) ->
                            Just version

                        ( Nothing, RemoteData.Success repo ) ->
                            Maybe.map .version (List.head repo.releases)

                        ( Nothing, _ ) ->
                            Nothing
            in
            ( { model | repoResponse = data }
            , case maybeVersion of
                Nothing ->
                    Effect.none

                Just version ->
                    Effect.sendCmd <|
                        Api.send HandleGetVersionResponse <|
                            Api.getVersion model.org model.repo version
            )

        HandleGetVersionResponse response ->
            let
                data =
                    RemoteData.fromResult response
            in
            ( { model | releaseResponse = data }
            , Effect.none
            )

        ToggleVersionDropdown isOpen ->
            ( { model | versionDropdownIsOpen = isOpen }
            , Effect.none
            )

        ChangeTab tab ->
            ( { model | hash = Just tab, selectedOutput = Nothing }
            , Effect.none
            )

        SearchInput query ->
            ( { model
                | searchQuery =
                    case query of
                        "" ->
                            Nothing

                        q ->
                            Just q
                , hash =
                    case query of
                        "" ->
                            model.hash

                        _ ->
                            Just "outputs"
              }
            , Effect.none
            )

        SelectOutput section attribute output systems ->
            ( { model
                | selectedOutput =
                    Just
                        { section = section
                        , output = output
                        , attribute = attribute
                        , systems = systems
                        }
                , hash = Just "outputs"
              }
            , Effect.none
            )

        SelectSystem system ->
            ( { model | system = system }
            , Effect.none
            )

        ExpandSection section ->
            ( { model | expandSections = section :: model.expandSections }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


viewRemoteData : WebData a -> (a -> View Msg) -> View Msg
viewRemoteData webdata viewData =
    case webdata of
        RemoteData.NotAsked ->
            { title = "flakestry"
            , body =
                Flakestry.Layout.viewBody
                    [ Flakestry.Layout.viewNav
                    , Flakestry.Layout.viewFooter
                    ]
            }

        RemoteData.Loading ->
            { title = "flakestry - loading"
            , body =
                Flakestry.Layout.viewBody
                    [ Flakestry.Layout.viewNav
                    , spinner
                    , Flakestry.Layout.viewFooter
                    ]
            }

        RemoteData.Failure err ->
            { title = "flakestry - failed"
            , body =
                Flakestry.Layout.viewBody
                    [ Flakestry.Layout.viewNav
                    , text "failure loading flakes"
                    , Flakestry.Layout.viewFooter
                    ]
            }

        RemoteData.Success a ->
            viewData a


view : Model -> View Msg
view model =
    viewRemoteData model.repoResponse
        (\repo ->
            let
                maybeRelease =
                    case model.version of
                        Nothing ->
                            List.head repo.releases

                        Just version ->
                            List.filter (\release -> release.version == version) repo.releases |> List.head
            in
            case maybeRelease of
                Nothing ->
                    { title = "Flakestry - 404"
                    , body =
                        Flakestry.Layout.viewBody
                            [ Flakestry.Layout.viewNav
                            , text "No such release exists."
                            , Flakestry.Layout.viewFooter
                            ]
                    }

                Just release ->
                    { title = "Flake " ++ release.owner ++ "/" ++ release.repo
                    , body =
                        Flakestry.Layout.viewBody
                            [ Flakestry.Layout.viewNav
                            , viewRelease model repo.releases release
                            , Flakestry.Layout.viewFooter
                            ]
                    }
        )


viewRelease : Model -> List Api.FlakeRelease -> Api.FlakeRelease -> Html Msg
viewRelease model releases release =
    let
        githubLink =
            "https://github.com/" ++ release.owner ++ "/" ++ release.repo
    in
    div [ class "container max-w-5xl px-4" ]
        [ div [ class "pt-16 pb-8 leading-6" ]
            [ h2 [ class "inline-flex items-center font-semibold text-2xl" ]
                [ img [ class "inline h-7 w-7 rounded border border-slate-300", src ("https://github.com/" ++ release.owner ++ ".png?size=128") ] []
                , a
                    [ class "ml-2 hover:text-sky-500"
                    , Route.Path.href (Route.Path.Flake_Github_Org_ { org = release.owner })
                    ]
                    [ text release.owner ]
                , span [ class "mx-2" ] [ text "/" ]
                , a
                    [ class "hover:text-sky-500"
                    , Route.Path.href (Route.Path.Flake_Github_Org__Repo_ { org = release.owner, repo = release.repo })
                    ]
                    [ text release.repo ]
                , a
                    [ href githubLink
                    , title "View source code on GitHub"
                    ]
                    [ Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.class "inline ml-4" |> Octicons.markGithub ]
                ]
            , viewVersionDropdown model releases release
            , p [ class "mt-3 text-sm items-center" ]
                [ Octicons.defaultOptions
                    |> Octicons.color "currentColor"
                    |> Octicons.class "inline"
                    |> Octicons.clock
                , span [ class "ml-1" ]
                    [ text <|
                        ApiTime.dateTimeToString release.createdAt
                    ]
                ]
            , p [ class "mt-3 text-lg" ] [ text release.description ]
            ]
        , viewOutputs model release
        ]


remoteRelease : Model -> (Api.Release -> Html Msg) -> Html Msg
remoteRelease model v =
    case model.releaseResponse of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            spinner

        RemoteData.Failure _ ->
            text "HTTP error happened"

        RemoteData.Success release ->
            v release


viewOutputs : Model -> Api.FlakeRelease -> Html Msg
viewOutputs model flakeRelease =
    remoteRelease model
        (\release ->
            let
                badgeMarkdown =
                    "[![flakestry.dev](https://flakestry.dev" ++ badgeImage ++ ")](https://flakestry.dev" ++ Route.Path.toString model.route ++ ")"

                badgeImage =
                    "/api/badge/flake/github/" ++ model.org ++ "/" ++ model.repo

                outputs =
                    parseOutputs release

                baseUrl =
                    "https://github.com/" ++ flakeRelease.owner ++ "/" ++ flakeRelease.repo

                revision =
                    case flakeRelease.commit of
                        Nothing ->
                            "HEAD"

                        Just "" ->
                            "HEAD"

                        Just commit ->
                            commit

                tab name hash icon =
                    let
                        isActive =
                            case model.hash of
                                Nothing ->
                                    "readme" == hash

                                Just h ->
                                    hash == h
                    in
                    li
                        [ class "mr-2"
                        ]
                        [ a
                            [ Route.href { hash = Just hash, path = model.route, query = Dict.empty }
                            , onClick (ChangeTab hash)
                            , class
                                ("""inline-block p-4 rounded-t-lg border-b-2 hover:text-blue-900 hover:border-blue-900 """
                                    ++ (if isActive then
                                            "text-blue-900 border-blue-900"

                                        else
                                            "border-transparent"
                                       )
                                )
                            ]
                            [ Octicons.defaultOptions
                                |> Octicons.color "currentColor"
                                |> Octicons.size 16
                                |> Octicons.class "inline shrink-0 mr-2"
                                |> icon
                            , text name
                            ]
                        ]
            in
            div
                [ class "grid grid-cols-3 sm:grid-cols-12 overflow-hidden rounded shadow"
                ]
                [ aside
                    [ class "col-span-3 h-full flex flex-col bg-white"
                    ]
                    [ div
                        [ class "px-4 py-2"
                        ]
                        [ Html.form [ class "flex place-items-center" ]
                            [ div
                                [ class "relative w-full"
                                ]
                                [ div
                                    [ class "absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none"
                                    ]
                                    [ svg
                                        [ SvgAttr.class "w-4 h-4 text-gray-500"
                                        , attribute "aria-hidden" "true"
                                        , SvgAttr.fill "none"
                                        , SvgAttr.viewBox "0 0 20 20"
                                        ]
                                        [ Svg.path
                                            [ SvgAttr.stroke "currentColor"
                                            , SvgAttr.strokeLinecap "round"
                                            , SvgAttr.strokeLinejoin "round"
                                            , SvgAttr.strokeWidth "2"
                                            , SvgAttr.d "m19 19-4-4m0-7A7 7 0 1 1 1 8a7 7 0 0 1 14 0Z"
                                            ]
                                            []
                                        ]
                                    ]
                                , input
                                    [ type_ "search"
                                    , id "default-search"
                                    , class """block w-full p-2 pl-10 text-sm text-black border border-gray-200 rounded-lg
                                            bg-transparent focus:ring-blue-500 focus:border-blue-500"""
                                    , placeholder "Search outputs ..."
                                    , onInput SearchInput
                                    ]
                                    []
                                ]
                            ]
                        ]
                    , nav
                        [ class "flex-1 overflow-y-auto p-4 space-y-2"
                        ]
                        (case outputs of
                            Ok o ->
                                viewOutputSections model o

                            Err err ->
                                [ text err ]
                        )
                    ]
                , main_
                    [ class "col-span-9 bg-white  border-l border-slate-100"
                    ]
                    [ div
                        [ class "text-sm font-medium text-center text-gray-500"
                        ]
                        [ ul
                            [ class "flex flex-wrap -mb-px"
                            ]
                            [ tab "README" "readme" Octicons.file
                            , tab "Inputs" "inputs" Octicons.package
                            ]
                        ]
                    , span [ class "ml-4 mt-4 inline-block" ]
                        [ img [ src badgeImage, class "inline-block" ] []
                        ]
                    , button
                        [ class "ml-2 clipboard inline-flex text-sm text-gray-900 font-medium p-2 shadow-sm rounded border border-gray-300 hover:bg-blue-600 hover:text-white hover:border-white"
                        , type_ "button"
                        , title "Copy badge markdown to clipboard"
                        , attribute "data-clipboard-text" badgeMarkdown
                        ]
                        [ Octicons.defaultOptions
                            |> Octicons.color "currentColor"
                            |> Octicons.size 10
                            |> Octicons.class "inline"
                            |> Octicons.clippy
                        ]
                    , case model.hash of
                        Just "inputs" ->
                            viewInputs release

                        Just "outputs" ->
                            viewOutput model

                        _ ->
                            File.defaultOptions
                                |> File.fileName "README"
                                |> File.class "markdown-body"
                                |> File.contents (Maybe.withDefault "" flakeRelease.readme)
                                |> File.baseUrl (baseUrl ++ "/blob/" ++ revision ++ "/")
                                |> File.rawBaseUrl (baseUrl ++ "/raw/" ++ revision ++ "/")
                                |> File.file
                    ]
                ]
        )


viewOutput : Model -> Html Msg
viewOutput model =
    div [ class "p-4" ]
        [ case model.selectedOutput of
            Nothing ->
                text "Select an output in the side bar."

            Just output ->
                let
                    mkSystem system =
                        button
                            [ type_ "button"
                            , onClick (SelectSystem system)
                            , class
                                ((if system == model.system then
                                    "bg-black text-white"

                                  else
                                    "text-black bg-transparent"
                                 )
                                    ++ """ px-4 py-2 text-sm font-medium border m-2
                                    rounded-lg hover:bg-black hover:text-white"""
                                )
                            ]
                            [ text system ]

                    mkSection title =
                        div [ class "text-lg font-semibold mt-4" ] [ text title ]
                in
                div []
                    ((case List.map mkSystem output.systems of
                        [] ->
                            []

                        systems ->
                            [ mkSection "systems"
                            , div
                                [ class "rounded-md m-4"
                                , attribute "role" "group"
                                ]
                                systems
                            ]
                     )
                        ++ (case output.output.name of
                                Nothing ->
                                    []

                                Just name ->
                                    [ mkSection "name"
                                    , span [ class "m-4" ] [ text name ]
                                    ]
                           )
                        ++ (case output.output.description of
                                Nothing ->
                                    []

                                Just description ->
                                    [ mkSection "description"
                                    , span [ class "m-4" ] [ text description ]
                                    ]
                           )
                        ++ [ mkSection "type"
                           , span [ class "m-4" ] [ text output.output.type_ ]
                           ]
                    )
        ]


viewInputs : Api.Release -> Html Msg
viewInputs release =
    let
        inputs =
            case release.metaData of
                Nothing ->
                    Dict.empty

                Just i ->
                    Flakestry.MetadataSchema.decodeRootInputsUrl i

        viewInput ( name, url ) =
            tr []
                [ td [ class "border px-4 py-2" ] [ text name ]
                , td [ class "border px-4 py-2" ] [ text url ]
                ]
    in
    div [ class "container mx-auto p-6" ]
        [ table [ class "min-w-full bg-white" ]
            [ thead []
                [ tr []
                    [ th [ class "w-1/3 text-left py-3 px-4 uppercase font-semibold text-sm" ] [ text "Input Name" ]
                    , th [ class "w-2/3 text-left py-3 px-4 uppercase font-semibold text-sm" ] [ text "URL" ]
                    ]
                ]
            , tbody []
                (List.map viewInput (Dict.toList inputs))
            ]
        ]


viewOutputSections : Model -> Flakestry.FlakeSchema.Root -> List (Html Msg)
viewOutputSections model root =
    let
        subsectionClasses =
            "flex items-center px-3 py-2 text-sm font-medium text-gray-700 rounded-md hover:bg-blue-900 hover:text-white"

        isSelectedOutput section name =
            case model.selectedOutput of
                Nothing ->
                    False

                Just output ->
                    output.section == section && output.attribute == name

        mkItem section systems ( name, derivation ) =
            if
                case model.searchQuery of
                    Nothing ->
                        False

                    Just query ->
                        not (String.contains query name)
            then
                text ""

            else
                li []
                    [ a
                        [ Route.href { hash = Just "outputs", path = model.route, query = Dict.empty }
                        , onClick (SelectOutput section name derivation systems)
                        , class <|
                            subsectionClasses
                                ++ (if isSelectedOutput section name then
                                        " bg-blue-900 text-white"

                                    else
                                        ""
                                   )
                        ]
                        [ span
                            [ class "ml-2"
                            ]
                            [ text name ]
                        ]
                    ]

        mkSubSection title attrs systems =
            let
                attrsList =
                    Dict.toList attrs

                ( attrsFinal, paginate ) =
                    case ( List.length attrsList > 10, List.member title model.expandSections, model.searchQuery ) of
                        ( True, False, Nothing ) ->
                            ( List.take 10 attrsList
                            , [ a
                                    [ onClick (ExpandSection title)
                                    , href "#outputs"
                                    , class subsectionClasses
                                    ]
                                    [ text "... Show more" ]
                              ]
                            )

                        _ ->
                            ( attrsList, [] )
            in
            div [] (List.map (mkItem title systems) attrsFinal ++ paginate)

        mkSection title maybeItems f =
            case maybeItems of
                Nothing ->
                    div [] []

                Just items ->
                    div []
                        [ div
                            [ class "text-sm font-semibold text-gray-500"
                            ]
                            [ text title ]
                        , ul
                            [ class "mt-2 space-y-1"
                            ]
                            [ f items ]
                        ]

        mkSystemSection title maybeItems =
            let
                f items =
                    case Dict.get model.system items of
                        Nothing ->
                            li [] [ text ("No outputs for " ++ model.system) ]

                        Just attrs ->
                            mkSubSection title attrs (Dict.keys items)
            in
            mkSection title maybeItems f

        mkSimpleSection title maybeItems =
            let
                f items =
                    mkSubSection title items []
            in
            mkSection title maybeItems f
    in
    [ mkSystemSection "packages" root.packages
    , mkSystemSection "legacyPackages" root.legacyPacakges
    , mkSystemSection "devShells" root.devShells
    , mkSystemSection "checks" root.checks
    , mkSystemSection "apps" root.apps
    , mkSimpleSection "templates" root.templates
    , mkSimpleSection "formatter" root.formatter
    , mkSimpleSection "overlays" root.overlays
    , mkSimpleSection "nixosModules" root.nixosModules
    , mkSimpleSection "nixosConfigurations" root.nixosConfigurations
    ]


parseOutputs : Api.Release -> Result String Flakestry.FlakeSchema.Root
parseOutputs release =
    case release.outputs of
        Nothing ->
            Err "No outputs found"

        Just jsonOutputs ->
            case Flakestry.FlakeSchema.decodeJson jsonOutputs of
                Ok o2 ->
                    Ok o2

                Err err ->
                    Err (Json.Decode.errorToString err)


spinner : Html msg
spinner =
    svg
        [ SvgAttr.class "animate-spin h-5 w-5 text-black"
        , SvgAttr.fill "none"
        , SvgAttr.viewBox "0 0 24 24"
        ]
        [ Svg.circle
            [ SvgAttr.class "opacity-25"
            , SvgAttr.cx "12"
            , SvgAttr.cy "12"
            , SvgAttr.r "10"
            , SvgAttr.stroke "currentColor"
            , SvgAttr.strokeWidth "4"
            ]
            []
        , Svg.path
            [ SvgAttr.class "opacity-75"
            , SvgAttr.fill "currentColor"
            , SvgAttr.d "M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            ]
            []
        ]


thisRoute : { org : String, repo : String, version : Maybe String } -> Route.Path.Path
thisRoute model =
    Route.Path.Flake_Github_Org__Repo__Version_ { org = model.org, repo = model.repo, version = Maybe.withDefault "" model.version }


viewVersionDropdown : Model -> List Api.FlakeRelease -> Api.FlakeRelease -> Html Msg
viewVersionDropdown model releases release =
    let
        tag =
            Octicons.defaultOptions
                |> Octicons.color "currentColor"
                |> Octicons.class "inline mr-2"
                |> Octicons.tag

        mkVersion =
            \r ->
                a
                    [ class "p-2 hover:underline hover:cursor-pointer"
                    , Route.Path.href (thisRoute { org = r.owner, repo = r.repo, version = Just r.version })
                    ]
                    [ tag, text r.version ]
    in
    Dropdown.dropdown
        { identifier = "version-dropdown"
        , toggleEvent = Dropdown.OnClick
        , drawerVisibleAttribute = class "visible"
        , onToggle = ToggleVersionDropdown
        , layout =
            \{ toDropdown, toToggle, toDrawer } ->
                toDropdown div
                    [ class "ml-6" ]
                    [ toToggle button
                        [ class "flex items-center justify-between pl-2 pr-3 py-2 border rounded shadow-sm text-slate-900 bg-slate-100"
                        , type_ "button"
                        , attribute "aria-label" "Version"
                        ]
                        [ tag
                        , text release.version
                        , Octicons.defaultOptions |> Octicons.color "currentColor" |> Octicons.class "inline ml-3" |> Octicons.chevronDown
                        ]
                    , toDrawer div
                        [ class "grid grid-cols-1 items-center justify-between pl-2 pr-3 py-2 border rounded shadow-sm text-slate-900 bg-slate-100" ]
                        (List.map mkVersion releases)
                    ]
        , isToggled = model.versionDropdownIsOpen
        }
