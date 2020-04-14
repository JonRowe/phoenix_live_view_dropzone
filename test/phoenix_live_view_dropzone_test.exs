defmodule PhoenixLiveViewDropzoneTest do
  use ExUnit.Case
  import Phoenix.LiveViewTest, only: [render_component: 2]

  @endpoint PhoenixLiveViewDropzone.Test.App

  test "render creates a div" do
    assert render([]) =~ ~r{<div\s*[^>]*>\s*</div>}
  end

  test "it defaults the id to phoenix-live-view-dropzone" do
    assert render([]) =~ ~r{<div\s*[^>]*id="phoenix-live-view-dropzone"[^>]*>\s*</div>}
  end

  test "it allows customising the id" do
    assert render([dom_id: "custom_id"]) =~ ~r{<div\s*[^>]*id="custom_id"[^>]*>\s*</div>}
  end

  test "it defaults the css class to phoenix-live-view-dropzone" do
    assert render([]) =~ ~r{<div\s*[^>]*class="phoenix-live-view-dropzone"[^>]*>\s*</div>}
  end

  test "it allows customising the css class" do
    assert render([css_class: "custom_class"]) =~ ~r{<div\s*[^>]*class="custom_class"[^>]*>\s*</div>}
  end

  test "it defaults data-id and data-url to blank" do
    assert render([]) =~ ~r{<div\s*[^>]*data-id=""[^>]*>\s*</div>}
    assert render([]) =~ ~r{<div\s*[^>]*data-url=""[^>]*>\s*</div>}
  end

  test "it sets data-id and data-url from file_data" do
    data = %{id: "custom-id", url: "custom-url"}
    assert render([file_data: data]) =~ ~r{<div\s*[^>]*data-id="#{data[:id]}"[^>]*>\s*</div>}
    assert render([file_data: data]) =~ ~r{<div\s*[^>]*data-url="#{data[:url]}"[^>]*>\s*</div>}
  end

  test "it sets phx-update to ignore" do
    assert render([]) =~ ~r{<div\s*[^>]*phx-update="ignore"[^>]*>\s*</div>}
  end

  test "it sets the default hook name as PhoenixLiveViewDropzone" do
    assert render([]) =~ ~r{<div\s*[^>]*phx-hook="PhoenixLiveViewDropzone"[^>]*>\s*</div>}
  end

  test "it allows customising the hook name" do
    assert render([hook: "Custom"]) =~ ~r{<div\s*[^>]*phx-hook="Custom"[^>]*>\s*</div>}
  end

  test "it allows customising the button test" do
    assert render([button_text: "Custom"]) =~ ~r{<div\s*[^>]*data-button-text="Custom"[^>]*>\s*</div>}
  end

  test "it allows customising the file types with a string" do
    assert render([file_types: "application/custom,image/png"]) =~ ~r{<div\s*[^>]*data-file-types="application/custom,image/png"[^>]*>\s*</div>}
  end

  test "it allows customising the file types with a list of strings" do
    assert render([file_types: ~w[application/custom image/png]]) =~ ~r{<div\s*[^>]*data-file-types="application/custom,image/png"[^>]*>\s*</div>}
  end

  test "it allows setting dropzone text" do
    assert render([text: "Custom"]) =~ ~r{<div\s*[^>]*data-text="Custom"[^>]*>\s*</div>}
  end

  defp render(assigns), do: render_component(PhoenixLiveViewDropzone, assigns)
end
