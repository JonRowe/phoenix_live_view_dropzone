defmodule PhoenixLiveViewDropzone.Test.App do
  use Phoenix.Endpoint, otp_app: :phoenix_live_view_dropzone_test_app

  # Assert we are in the test environment.
  :test = Mix.env()

  @session_options [
    store: :cookie,
    key: "_phoenix_live_view_dropzone_test_key",
    encryption_salt: :crypto.strong_rand_bytes(15) |> Base.url_encode64(),
    signing_salt: :crypto.strong_rand_bytes(5) |> Base.url_encode64()
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options], check_origin: false]

  defmodule __MODULE__.Router do
    use Phoenix.Router
    import Phoenix.LiveView.Router
  end

  plug Router
end
