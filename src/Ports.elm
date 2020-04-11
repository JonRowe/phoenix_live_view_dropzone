port module Ports exposing (addUploadUrl, notifyUploadStatus, requestUrl)

import Json.Encode exposing (Value)


port requestUrl : String -> Cmd msg


port addUploadUrl : (String -> msg) -> Sub msg


port notifyUploadStatus : { fileId : String, status : String } -> Cmd msg
