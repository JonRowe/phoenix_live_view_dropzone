module Upload exposing (Upload, UploadId, UploadStatus, UploadTarget, createUpload, updateUploadProgress, uploadStatus)

import File exposing (File)
import Http exposing (Progress(..))
import Task exposing (Task)
import Time exposing (Posix)


type alias UploadId =
    String


type alias Upload =
    { file : File
    , id : UploadId
    , name : String
    , progress : Int
    , sent : Int
    , size : Int
    }


type alias UploadTarget =
    { id : UploadId
    , url : String
    }


type alias UploadStatus =
    { filename : String, id : UploadId, progress : Int, status : String }


createUpload : File -> Task x Upload
createUpload file =
    let
        idFromTime : Posix -> UploadId
        idFromTime posix =
            Time.posixToMillis posix |> String.fromInt

        generateId : Posix -> Task x UploadId
        generateId =
            Task.succeed << idFromTime

        setIdInUpload : UploadId -> Task x Upload
        setIdInUpload =
            Task.succeed << makeUpload file
    in
    Time.now |> Task.andThen generateId |> Task.andThen setIdInUpload


makeUpload : File -> String -> Upload
makeUpload file id =
    let
        name : String
        name =
            File.name file

        size : Int
        size =
            File.size file
    in
    { file = file, id = id, name = name, progress = 0, sent = 0, size = size }


updateUploadProgress : Upload -> Progress -> Upload
updateUploadProgress upload progress =
    case progress of
        Sending data ->
            let
                percentage : Int
                percentage =
                    ceiling ((toFloat data.sent / toFloat upload.size) * 100)
            in
            { upload | progress = percentage, sent = data.sent }

        _ ->
            upload


uploadStatus : Upload -> String -> UploadStatus
uploadStatus upload status =
    { id = upload.id, filename = upload.name, status = status, progress = upload.progress }
