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
import Upload exposing (Upload, UploadId, createUpload, updateUploadProgress, uploadStatus)


type alias Model =
    { types : List String
    , upload : Maybe Upload
    }


type Msg
    = OpenFileSelect
    | FileSelected File
    | StartUpload Upload
    | UrlGenerated String
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
    , upload = Nothing
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        urlSub : Sub Msg
        urlSub =
            Ports.addUploadUrl UrlGenerated
    in
    case model.upload of
        Just upload ->
            Sub.batch [ urlSub, Http.track upload.id (UploadProgress upload) ]

        _ ->
            urlSub


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


notifyUploadStatus : Model -> String -> Cmd Msg
notifyUploadStatus model status =
    case model.upload of
        Just upload ->
            Ports.notifyUploadStatus (uploadStatus upload status)

        _ ->
            Cmd.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OpenFileSelect ->
            ( model, Select.file model.types FileSelected )

        FileSelected file ->
            ( model, Task.perform StartUpload (createUpload file) )

        StartUpload upload ->
            ( { model | upload = Just upload }, Ports.requestUrl { id = upload.id, filename = upload.name } )

        UrlGenerated url ->
            case model.upload of
                Just upload ->
                    ( model, startUpload upload url )

                _ ->
                    ( model, Cmd.none )

        UploadProgress upload progress ->
            let
                updated : Upload
                updated =
                    updateUploadProgress upload progress
            in
            ( { model | upload = Just updated }, Ports.notifyUploadStatus (uploadStatus updated "InProgress") )

        Done uploadId ->
            ( none, notifyUploadStatus model "Done" )

        Error uploadId ->
            ( none, notifyUploadStatus model "Error" )


view : Model -> Html Msg
view model =
    let
        filename : Maybe Upload -> String
        filename possibleUpload =
            case possibleUpload of
                Just upload ->
                    "Filename: " ++ upload.name

                _ ->
                    "Filename: not set"
    in
    div []
        [ button [ onClick OpenFileSelect ] [ text "Upload" ]
        , br [] []
        , text (filename model.upload)
        ]


main : Program Value Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
