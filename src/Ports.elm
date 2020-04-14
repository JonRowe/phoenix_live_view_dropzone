port module Ports exposing (addUploadUrl, notifyUploadStatus, requestUrl)

import Json.Encode exposing (Value)
import Upload exposing (Upload, UploadExport, UploadId, UploadTarget, export)


port requestUrl : { id : UploadId, filename : String } -> Cmd msg


port addUploadUrl : (UploadTarget -> msg) -> Sub msg


port uploadStatus : UploadExport -> Cmd msg


notifyUploadStatus : Upload -> Cmd msg
notifyUploadStatus upload =
    uploadStatus (export upload)
