port module Ports exposing (addUploadUrl, notifyUploadStatus, requestUrl)

import Json.Encode exposing (Value)


port requestUrl : { id : String, filename : String } -> Cmd msg


port addUploadUrl : (String -> msg) -> Sub msg


port notifyUploadStatus : { id : String, filename : String, status : String, progress : Int } -> Cmd msg
