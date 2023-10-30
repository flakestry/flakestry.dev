module Flakestry.FlakeSchema exposing (Derivation, Lib, Platform, Root, decodeJson)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, dict, field, maybe, string)



-- Type definitions


type alias Derivation =
    { description : String
    , name : String
    , type_ : String
    }


type alias Platform =
    Dict String (Dict String Derivation)


type alias Lib =
    { type_ : String
    }



-- https://nixos.wiki/wiki/Flakes#Flake_schema


type alias Root =
    { checks : Maybe Platform
    , lib : Maybe Lib
    , packages : Maybe Platform
    , legacyPacakges : Maybe Platform
    , devShells : Maybe Platform
    }



-- Decoders


derivationDecoder : Decoder Derivation
derivationDecoder =
    Decode.map3 Derivation
        (field "description" string)
        (field "name" string)
        (field "type" string)


platformDecoder : Decoder Platform
platformDecoder =
    dict (dict derivationDecoder)


libDecoder : Decoder Lib
libDecoder =
    Decode.map Lib (field "type" string)


rootDecoder : Decoder Root
rootDecoder =
    Decode.map5 Root
        (maybe (field "checks" platformDecoder))
        (maybe (field "lib" libDecoder))
        (maybe (field "packages" platformDecoder))
        (maybe (field "legacyPackages" platformDecoder))
        (maybe (field "devShells" platformDecoder))


decodeJson : Decode.Value -> Result Decode.Error Root
decodeJson jsonString =
    Decode.decodeValue rootDecoder jsonString
