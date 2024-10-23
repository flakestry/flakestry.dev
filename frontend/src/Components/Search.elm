module Components.Search exposing (..)

import Api
import Api.Data as Api
import Api.Request.Api as Api
import Debouncer.Basic as Debouncer exposing (Debouncer)
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import RemoteData exposing (WebData)
import Svg
import Svg.Attributes as SvgAttr


type alias Model =
    { query : Maybe String
    , searchResponse : WebData Api.GetFlakeResponse
    , debouncer : Debouncer Msg Msg
    }


type Msg
    = SetQuery String
    | Search
    | HandleSearchResponse (Result Http.Error Api.GetFlakeResponse)
    | Debounce (Debouncer.Msg Msg)
    | KeyDown String


init : Maybe String -> Model
init query =
    { query = query
    , searchResponse = RemoteData.NotAsked
    , debouncer =
        Debouncer.manual
            |> Debouncer.settleWhenQuietFor (Just <| Debouncer.fromSeconds 0.45)
            |> Debouncer.emitWhileUnsettled (Just <| Debouncer.fromSeconds 1.0)
            |> Debouncer.toDebouncer
    }


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SetQuery query ->
            let
                searchMsg =
                    Search |> Debouncer.provideInput |> Debounce

                newQuery =
                    if String.isEmpty query then
                        Nothing

                    else
                        Just query

                ( newModel, debounceCmd ) =
                    update searchMsg { model | query = newQuery }
            in
            ( newModel, debounceCmd )

        Search ->
            let
                searchCmd =
                    case model.query of
                        Nothing ->
                            Effect.none

                        _ ->
                            Effect.sendCmd <|
                                Api.send HandleSearchResponse <|
                                    Api.getFlake model.query
            in
            ( model
            , searchCmd
            )

        HandleSearchResponse response ->
            ( { model | searchResponse = RemoteData.fromResult response }
            , Effect.none
            )

        Debounce subMsg ->
            let
                ( subModel, subCmd, emittedMsg ) =
                    Debouncer.update subMsg model.debouncer

                mappedCmd =
                    Cmd.map Debounce subCmd

                updatedModel =
                    { model | debouncer = subModel }
            in
            case emittedMsg of
                Just emitted ->
                    -- Send the emitted message as a command, instead of running the update manually.
                    -- This lets the parent view and react to the message.
                    ( updatedModel, Effect.batch [ Effect.sendMsg emitted, Effect.sendCmd mappedCmd ] )

                Nothing ->
                    ( updatedModel, Effect.sendCmd mappedCmd )

        KeyDown key ->
            if key == "Enter" then
                ( model, Effect.sendMsg Search )

            else
                ( model, Effect.none )


view : { onSearch : Msg -> msg } -> Model -> Html msg
view props model =
    label [ class "max-w-3xl mx-auto relative block mt-8" ]
        [ span [ class "sr-only" ] [ text "Search" ]
        , span [ class "absolute inset-y-0 left-0 flex items-center pl-4" ]
            [ Svg.svg
                [ SvgAttr.viewBox "0 0 20 20"
                , SvgAttr.class "h-6 w-6 fill-slate-400"
                ]
                [ Svg.path
                    [ SvgAttr.fillRule "evenodd"
                    , SvgAttr.clipRule "evenodd"
                    , SvgAttr.d "M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z"
                    ]
                    []
                ]
            ]
        , input
            [ class "placeholder:text-slate-400 text-lg block bg-white w-full border border-slate-300 rounded-md py-4 pl-14 pr-3 shadow-md focus:outline-none focus:border-sky-500 focus:ring-sky-500 focus:ring-1"
            , placeholder "Search for flakes..."
            , type_ "text"
            , name "search"
            , onInput (\query -> SetQuery query |> props.onSearch)
            , onKeyDown (\keyCode -> KeyDown keyCode |> props.onSearch)
            , value (Maybe.withDefault "" model.query)
            ]
            []
        ]


onKeyDown : (String -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Decode.map tagger keyDecoder)


keyDecoder : Decode.Decoder String
keyDecoder =
    Decode.field "key" Decode.string
