defmodule PhoenixLiveViewDropzoneTest do
  use ExUnit.Case
  import Phoenix.LiveViewTest

  @endpoint PhoenixLiveViewDropzone.Test.App

  test "render creates a div" do
    assert render_component(PhoenixLiveViewDropzone, []) =~ ~r{<div [^>]*>\s*</div>}
  end
end
