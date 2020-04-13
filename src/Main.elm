module Main exposing (main)

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (Html, br, button, div, text)
import Html.Events exposing (onClick)
import Http exposing (Progress)
import Json.Decode as Json exposing (Value)
import Ports
import Task exposing (Task)
import Upload exposing (Upload, UploadId, UploadTarget, createUpload, updateUploadProgress, uploadStatus)
import Uploads exposing (Uploads)


type alias Model =
    { types : List String
    , uploads : Uploads
    }


type Msg
    = OpenFileSelect
    | FileSelected File
    | StartUpload Upload
    | UrlGenerated UploadTarget
    | UploadProgress Upload Progress
    | Error UploadId
    | Done UploadId


init : Value -> ( Model, Cmd Msg )
init config =
    ( none, Cmd.none )


filetypes : List String
filetypes =
    [ "application/octext"
    , "txt/plain"
    ]


none : Model
none =
    { types = filetypes
    , uploads = Uploads.empty
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        urlSub : Sub Msg
        urlSub =
            Ports.addUploadUrl UrlGenerated
    in
    Sub.batch ([ urlSub ] ++ Uploads.subscribe model.uploads UploadProgress)


startUpload : Upload -> String -> Cmd Msg
startUpload upload url =
    let
        handleResponse : Result Http.Error String -> Msg
        handleResponse result =
            case result of
                Ok string ->
                    Done upload.id

                _ ->
                    Error upload.id
    in
    Http.request
        { method = "PUT"
        , headers = []
        , url = url
        , body = Http.fileBody upload.file
        , expect = Http.expectString handleResponse
        , timeout = Nothing
        , tracker = Just upload.id
        }


notifyUploadStatus : UploadId -> Uploads -> String -> Cmd Msg
notifyUploadStatus id uploads status =
    case Uploads.get uploads id of
        Just upload ->
            Ports.notifyUploadStatus (uploadStatus upload status)

        _ ->
            Cmd.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        setUpload : Upload -> Model
        setUpload upload =
            { model | uploads = Uploads.update model.uploads upload }

        setUploadStatus : UploadId -> String -> ( Model, Cmd Msg )
        setUploadStatus id status =
            let
                newModel : Model
                newModel =
                    { model | uploads = Uploads.delete model.uploads id }
            in
            ( newModel, notifyUploadStatus id model.uploads status )
    in
    case msg of
        OpenFileSelect ->
            ( model, Select.file model.types FileSelected )

        FileSelected file ->
            ( model, Task.perform StartUpload (createUpload file) )

        StartUpload upload ->
            ( setUpload upload, Ports.requestUrl { id = upload.id, filename = upload.name } )

        UrlGenerated target ->
            case Uploads.get model.uploads target.id of
                Just upload ->
                    ( model, startUpload upload target.url )

                _ ->
                    ( model, Cmd.none )

        UploadProgress upload progress ->
            let
                updated : Upload
                updated =
                    updateUploadProgress upload progress
            in
            ( setUpload updated, Ports.notifyUploadStatus (uploadStatus updated "InProgress") )

        Done uploadId ->
            setUploadStatus uploadId "Done"

        Error uploadId ->
            setUploadStatus uploadId "Error"


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick OpenFileSelect ] [ text "Upload" ]
        ]


main : Program Value Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
