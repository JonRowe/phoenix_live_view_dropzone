module Upload exposing (Upload, UploadStatus, createUpload, uploadStatus)

import Bytes exposing (Bytes)
import File exposing (File)
import SHA256 as SHA
import Task exposing (Task)


type alias Upload =
    { file : File
    , id : String
    , name : String
    }


type alias UploadStatus =
    { filename : String, id : String, progress : Int, status : String }


createUpload : File -> Task x Upload
createUpload file =
    let
        convertToBytes : File -> Task x Bytes
        convertToBytes =
            File.toBytes

        bytesToHash : Bytes -> Task x String
        bytesToHash =
            Task.succeed << hashFromBytes

        setIdInUpload : String -> Task x Upload
        setIdInUpload =
            Task.succeed << makeUpload file
    in
    file |> File.toBytes |> Task.andThen bytesToHash |> Task.andThen setIdInUpload


hashFromBytes : Bytes -> String
hashFromBytes bytes =
    bytes
        |> SHA.fromBytes
        |> SHA.toHex


makeUpload : File -> String -> Upload
makeUpload file id =
    let
        filename : String
        filename =
            File.name file
    in
    { file = file, id = id, name = filename }


uploadStatus : Upload -> String -> Int -> UploadStatus
uploadStatus upload status progress =
    { id = upload.id, filename = upload.name, status = status, progress = progress }
