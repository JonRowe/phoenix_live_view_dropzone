port module Ports exposing (addUploadUrl, notifyUploadStatus, requestUrl)

import Json.Encode exposing (Value)
import Upload exposing (UploadId, UploadStatus, UploadTarget)


port requestUrl : { id : String, filename : String } -> Cmd msg


port addUploadUrl : (UploadTarget -> msg) -> Sub msg


port notifyUploadStatus : UploadStatus -> Cmd msg
