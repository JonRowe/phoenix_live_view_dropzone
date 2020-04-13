module Main exposing (main)

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (Html, br, button, div, text)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Json exposing (Value)
import Ports


type alias Model =
    { file : Maybe File
    , types : List String
    , url : Maybe String
    }


type Msg
    = OpenFileSelect
    | StartUpload File
    | UrlGenerated String
    | Error File Int
    | Done File


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
    { file = Nothing
    , types = filetypes
    , url = Nothing
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.addUploadUrl UrlGenerated


uploadFile : File -> String -> Cmd Msg
uploadFile file url =
    let
        handleResponse : Result Http.Error String -> Msg
        handleResponse result =
            case result of
                Ok string ->
                    Done file

                _ ->
                    Error file 0
    in
    Http.request
        { method = "PUT"
        , headers = []
        , url = url
        , body = Http.fileBody file
        , expect = Http.expectString handleResponse
        , timeout = Nothing
        , tracker = Nothing
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        uploadStatus : File -> String -> Int -> { filename : String, id : String, progress : Int, status : String }
        uploadStatus file status progress =
            { id = File.name file, filename = File.name file, status = status, progress = progress }
    in
    case msg of
        OpenFileSelect ->
            ( model, Select.file model.types StartUpload )

        StartUpload file ->
            ( { model | file = Just file }, Ports.requestUrl { id = File.name file, filename = File.name file } )

        UrlGenerated url ->
            let
                cmd =
                    case model.file of
                        Just file ->
                            uploadFile file url

                        _ ->
                            Cmd.none
            in
            ( { model | url = Just url }, cmd )

        Done file ->
            ( none, Ports.notifyUploadStatus (uploadStatus file "Done" 100) )

        Error file progress ->
            ( none, Ports.notifyUploadStatus (uploadStatus file "Error" progress) )


view : Model -> Html Msg
view model =
    let
        filename : Maybe File -> String
        filename possibleFile =
            case possibleFile of
                Just file ->
                    "Filename: " ++ File.name file

                _ ->
                    "Filename: not set"

        url : Maybe String -> String
        url possibleString =
            case possibleString of
                Just string ->
                    "URL: " ++ string

                _ ->
                    "URL: not set"
    in
    div []
        [ button [ onClick OpenFileSelect ] [ text "Upload" ]
        , br [] []
        , text (filename model.file)
        , br [] []
        , text (url model.url)
        ]


main : Program Value Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
