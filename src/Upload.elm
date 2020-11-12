module Upload exposing (Upload, UploadExport, UploadId, UploadStatus(..), UploadTarget, createUpload, export, updateUploadProgress)

import File exposing (File)
import Http exposing (Progress(..))
import Task exposing (Task)
import Time exposing (Posix)


type alias UploadId =
    String


type UploadStatus
    = InProgress
    | Done
    | Error


type alias UploadExport =
    { id : UploadId
    , name : String
    , progress : Int
    , sent : Int
    , size : Int
    , status : String
    , body : Maybe String
    }


type alias Upload =
    { file : File
    , id : UploadId
    , name : String
    , progress : Int
    , sent : Int
    , size : Int
    , status : UploadStatus
    , body : Maybe String
    }


type alias UploadTarget =
    { id : UploadId
    , url : String
    }


createUpload : (Upload -> msg) -> File -> Cmd msg
createUpload msg file =
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
    Time.now |> Task.andThen generateId |> Task.andThen setIdInUpload |> Task.perform msg


export : Upload -> UploadExport
export upload =
    let
        status : String
        status =
            case upload.status of
                InProgress ->
                    "InProgress"

                Done ->
                    "Done"

                Error ->
                    "Error"
    in
    { id = upload.id, name = upload.name, progress = upload.progress, sent = upload.sent, size = upload.size, status = status, body = upload.body }


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
    { file = file, id = id, name = name, progress = 0, sent = 0, size = size, status = InProgress, body = Nothing }


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
