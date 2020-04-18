# Phoenix Live View Dropzone

A file upload solution for Phoenix Live View.

## Use case

When you wish to upload file(s) in the background of your Live View to a pre authenticated resource.

This can be a route within your Phoenix app, or it can be to a 3rd party store such as S3. \
This implementation was developed against an application that provided S3 signed urls for uploads.

## Usage

Use the provided `PhoenixLiveViewDropzone` stateless Live Component for integration into your view.

e.g.

```elixir
  <%= live_component @socket, PhoenixLiveViewDropzone, file_data: @file_data %>
```

Where `@file_data` is expected to be a map `%{"id" => id, "url" => url}` which can be blank by default.


When a file is uploaded the view will emit `phx-dropzone` events via live view in the following structure:

```
[event_name, event_payload]
```

e.g. `handle_event/3` would be implemented as:

```
def handle_event("phx-dropzone", [_event, _payload], socket) do
  {:noreply, socket}
end
```

There are two events currently supported:

1) `generate-url`

Is issued on the file first being selected to generate a url to upload to. The payload is:

```elixir
%{"id" => "string-id-for-file", "name" => "string-filename-on-disk" }
```

To respond to this you are expected to assign `file_data` to `%{"id" => id, "url" => your_url}`. \
You need to do this only long enough for the updated hook to fire and uploading to begin.

2) `file-status`

Is issued as the file is uploaded, and on completion. The payload id:

```elixir
%{
  "id" => "string-id-for-file",        # the files id
  "name" => "string-filename-on-disk", # the files name
  "progress" => 42,                    # as a percentage
  "sent" => 42,                        # as a number of bytes sent
  "size" => 100,                       # size of file in bytes
  "status" => "string"                 # one of inProgress, Done, Error
}
```


### Options

  The following assigns can be set to customise various attributes:

  * `dom_id` - string - Sets the id attribute on the outer div, defaults to `phoenix-live-view-dropzone`.
  * `css_class` - string - Sets the class attribute on the outer div, defaults to `phoenix-live-view-dropzone`.
  * `hook_name` - string - Sets the `phx-hook` value on the outer div, defaults to `PhoenixLiveViewDropzone`.
  * `button_text` - string - Sets the text of the button in the drop zone.
  * `file_types` - string or list of strings - Sets the mime types the file picker will allow.
  * `target` - string - Sets the phx-target value for events.
  * `text` - string - Sets text that will be displayed above the button in the dropzone.

## Installation

This package assumes you have a working Live View setup. Follow the instructions for setting up live view first.

Then the package can be installed by adding `phoenix_live_view_dropzone` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:phoenix_live_view_dropzone, "~> 0.1.0"}
  ]
end
```

You then need to wire up the package dependency, in your package.json add:

```
  "phoenix_live_view_drop_zone": "file:../deps/phoenix_live_view_dropzone"
```

And connect the hook.

```javascript
let Hooks = {};
Hooks.PhoenixLiveViewDropzone = new PhoenixLiveViewDropzone();

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}});
liveSocket.connect()
```
