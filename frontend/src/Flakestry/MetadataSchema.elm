module Flakestry.MetadataSchema exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, Value, dict, field, map, map2, map4, maybe, string)


type alias Locked =
    { owner : String
    , repo : String
    , rev : String
    , type_ : String
    }


lockedDecoder : Decoder Locked
lockedDecoder =
    map4 Locked
        (field "owner" string)
        (field "repo" string)
        (field "rev" string)
        (field "type" string)


type alias Node =
    { inputs : Maybe (Dict String String)
    , locked : Maybe Locked
    }


nodeDecoder : Decoder Node
nodeDecoder =
    map2 Node
        (maybe (field "inputs" (dict string)))
        (maybe (field "locked" lockedDecoder))


type alias RootData =
    { locks : Locks
    }


type alias Locks =
    { nodes : Dict String Node
    , root : String
    }


locksDecoder : Decoder Locks
locksDecoder =
    map2 Locks
        (field "nodes" (dict nodeDecoder))
        (field "root" string)


extractRootInputsUrl : Locks -> Dict String String
extractRootInputsUrl locks =
    case Dict.get locks.root locks.nodes of
        Just rootNode ->
            Dict.map
                (\_ inputName ->
                    case Dict.get inputName locks.nodes of
                        Just node ->
                            case node.locked of
                                Just locked ->
                                    locked.type_ ++ ":" ++ locked.owner ++ "/" ++ locked.repo ++ "/" ++ locked.rev

                                Nothing ->
                                    ""

                        Nothing ->
                            ""
                )
                (Maybe.withDefault Dict.empty rootNode.inputs)

        Nothing ->
            Dict.empty


rootDataDecoder : Decoder RootData
rootDataDecoder =
    map RootData
        (field "locks" locksDecoder)


decodeRootInputsUrl : Value -> Dict String String
decodeRootInputsUrl json =
    case Decode.decodeValue rootDataDecoder json of
        Ok { locks } ->
            extractRootInputsUrl locks

        Err err ->
            Dict.singleton "error" (Decode.errorToString err)
