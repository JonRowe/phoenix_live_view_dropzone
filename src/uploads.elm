module Uploads exposing (Uploads, delete, empty, get, subscribe, update)

import Dict exposing (Dict)
import Http exposing (Progress)
import Upload exposing (Upload, UploadId)


type alias Uploads =
    Dict UploadId Upload


delete : Uploads -> UploadId -> Uploads
delete uploads id =
    Dict.remove id uploads


empty : Uploads
empty =
    Dict.empty


get : Uploads -> UploadId -> Maybe Upload
get uploads id =
    Dict.get id uploads


subscribe : Uploads -> (Upload -> Progress -> msg) -> List (Sub msg)
subscribe uploads msg =
    let
        subscription : Upload -> Sub msg
        subscription upload =
            Http.track upload.id (msg upload)
    in
    uploads
        |> Dict.values
        |> List.map subscription


update : Uploads -> Upload -> Uploads
update uploads upload =
    let
        setUpload : Maybe Upload -> Maybe Upload
        setUpload _ =
            Just upload
    in
    Dict.update upload.id setUpload uploads
