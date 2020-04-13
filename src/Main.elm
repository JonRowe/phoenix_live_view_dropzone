module Main exposing (main)

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (Html, br, button, div, text)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Json exposing (Value)
import Ports
import Upload exposing (Upload, createUpload, uploadStatus)


type alias Model =
    { types : List String
    , upload : Maybe Upload
    }


type Msg
    = OpenFileSelect
    | StartUpload Upload
    | UrlGenerated String
    | Error Upload
    | Done Upload


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
    Ports.addUploadUrl UrlGenerated


startUpload : Upload -> String -> Cmd Msg
startUpload upload url =
    let
        handleResponse : Result Http.Error String -> Msg
        handleResponse result =
            case result of
                Ok string ->
                    Done upload

                _ ->
                    Error upload
    in
    Http.request
        { method = "PUT"
        , headers = []
        , url = url
        , body = Http.fileBody upload.file
        , expect = Http.expectString handleResponse
        , timeout = Nothing
        , tracker = Nothing
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OpenFileSelect ->
            ( model, Select.file model.types (StartUpload << createUpload) )

        StartUpload upload ->
            ( { model | upload = Just upload }, Ports.requestUrl { id = upload.id, filename = upload.name } )

        UrlGenerated url ->
            case model.upload of
                Just upload ->
                    ( model, startUpload upload url )

                _ ->
                    ( model, Cmd.none )

        Done upload ->
            ( none, Ports.notifyUploadStatus (uploadStatus upload "Done" 100) )

        Error upload ->
            ( none, Ports.notifyUploadStatus (uploadStatus upload "Error" 0) )


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
