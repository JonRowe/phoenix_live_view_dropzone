module Upload exposing (Upload, UploadStatus, createUpload, uploadStatus)

import File exposing (File)


type alias Upload =
    { file : File
    , id : String
    , name : String
    }


type alias UploadStatus =
    { filename : String, id : String, progress : Int, status : String }


createUpload : File -> Upload
createUpload file =
    let
        filename : String
        filename =
            File.name file
    in
    { file = file, id = filename, name = filename }


uploadStatus : Upload -> String -> Int -> UploadStatus
uploadStatus upload status progress =
    { id = upload.id, filename = upload.name, status = status, progress = progress }
