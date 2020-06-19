module Main exposing (main)

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (Attribute, Html, br, button, div, text)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onClick, preventDefaultOn)
import Http exposing (Progress)
import Json.Decode as Json exposing (Value)
import Ports
import Task exposing (Task)
import Upload exposing (Upload, UploadId, UploadStatus(..), UploadTarget, createUpload, updateUploadProgress)
import Uploads exposing (Uploads)


type alias Model =
    { buttonText : String
    , fileTypes : List String
    , hover : Bool
    , text : String
    , uploads : Uploads
    }


type alias Config =
    { buttonText : String
    , fileTypes : List String
    }


type Msg
    = OpenFileSelect
    | SetHover Bool
    | FileSelected File (List File)
    | StartUpload Upload
    | UrlGenerated UploadTarget
    | UploadProgress Upload Progress
    | Error UploadId
    | Done UploadId


init : Value -> ( Model, Cmd Msg )
init config =
    let
        parseFrom : String -> a -> Json.Decoder a -> a
        parseFrom field default decoder =
            case Json.decodeValue (Json.field field decoder) config of
                Ok value ->
                    value

                _ ->
                    default

        parseTextFrom : String -> String -> String
        parseTextFrom field default =
            parseFrom field default Json.string

        buttonText : String
        buttonText =
            parseTextFrom "buttonText" "Upload"

        fileTypes : List String
        fileTypes =
            parseFrom "fileTypes" [] (Json.list Json.string)

        text : String
        text =
            parseTextFrom "text" ""
    in
    ( { buttonText = buttonText, fileTypes = fileTypes, hover = False, text = text, uploads = Uploads.empty }, Cmd.none )


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        notifyUploadStatus : UploadId -> UploadStatus -> Cmd Msg
        notifyUploadStatus id status =
            case Uploads.get model.uploads id of
                Just upload ->
                    Ports.notifyUploadStatus { upload | status = status }

                _ ->
                    Cmd.none

        setUpload : Upload -> Model
        setUpload upload =
            { model | uploads = Uploads.update model.uploads upload }

        setUploadStatus : UploadId -> UploadStatus -> ( Model, Cmd Msg )
        setUploadStatus id status =
            let
                newModel : Model
                newModel =
                    { model | uploads = Uploads.delete model.uploads id }
            in
            ( newModel, notifyUploadStatus id status )
    in
    case msg of
        OpenFileSelect ->
            ( model, Select.files model.fileTypes FileSelected )

        SetHover hover ->
            ( { model | hover = hover }, Cmd.none )

        FileSelected file files ->
            ( { model | hover = False }, file :: files |> List.map (createUpload StartUpload) |> Cmd.batch )

        StartUpload upload ->
            ( setUpload upload, Ports.requestUrl { id = upload.id, name = upload.name } )

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
            ( setUpload updated, Ports.notifyUploadStatus updated )

        Done uploadId ->
            setUploadStatus uploadId Upload.Done

        Error uploadId ->
            setUploadStatus uploadId Upload.Error


view : Model -> Html Msg
view model =
    let
        decodeDrop : Json.Decoder Msg
        decodeDrop =
            Json.at [ "dataTransfer", "files" ] (Json.oneOrMore FileSelected File.decoder)

        preventDefault : msg -> ( msg, Bool )
        preventDefault msg =
            ( msg, True )

        dragHandler : String -> Json.Decoder msg -> Attribute msg
        dragHandler event decoder =
            preventDefaultOn event (Json.map preventDefault decoder)
    in
    div
        [ if model.hover then
            class "drag-hovering"

          else
            class ""
        , dragHandler "dragenter" (Json.succeed (SetHover True))
        , dragHandler "dragover" (Json.succeed (SetHover True))
        , dragHandler "dragleave" (Json.succeed (SetHover False))
        , dragHandler "drop" decodeDrop
        ]
        [ text model.text
        , button [ onClick OpenFileSelect, type_ "button" ] [ text model.buttonText ]
        ]


main : Program Value Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
