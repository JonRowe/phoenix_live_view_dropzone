port module Ports exposing (addUploadUrl, notifyUploadStatus, requestUrl)

import Json.Encode exposing (Value)
import Upload exposing (UploadStatus)


port requestUrl : { id : String, filename : String } -> Cmd msg


port addUploadUrl : (String -> msg) -> Sub msg


port notifyUploadStatus : UploadStatus -> Cmd msg
