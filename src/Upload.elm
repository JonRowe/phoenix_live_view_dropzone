module Upload exposing (Upload, UploadId, UploadStatus, UploadTarget, createUpload, updateUploadProgress, uploadStatus)

import Bytes exposing (Bytes)
import File exposing (File)
import Http exposing (Progress(..))
import SHA256 as SHA
import Task exposing (Task)


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
        convertToBytes : File -> Task x Bytes
        convertToBytes =
            File.toBytes

        bytesToHash : Bytes -> Task x UploadId
        bytesToHash =
            Task.succeed << hashFromBytes

        setIdInUpload : UploadId -> Task x Upload
        setIdInUpload =
            Task.succeed << makeUpload file
    in
    file |> File.toBytes |> Task.andThen bytesToHash |> Task.andThen setIdInUpload


hashFromBytes : Bytes -> UploadId
hashFromBytes bytes =
    bytes
        |> SHA.fromBytes
        |> SHA.toHex


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
