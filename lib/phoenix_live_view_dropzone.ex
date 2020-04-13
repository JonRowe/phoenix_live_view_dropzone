defmodule PhoenixLiveViewDropzone do
  @moduledoc """
  """

  use Phoenix.LiveComponent

  @default_name "phoenix-live-view-dropzone"

  @doc """
  """
  def render(assigns) do
    ~L"""
    <div
      class="<%= css_class(assigns) %>"
      id="<%= id(assigns) %>"
      data-url="<%= data(assigns) %>"
      phx-update="ignore"
      phx-hook="<%= hook_name(assigns) %>"
    >
    </div>
    """
  end

  defp id(_), do: @default_name

  defp css_class(_), do: @default_name

  defp data(%{file_url: url}), do: url # ~s[{"id": "#{id}", "url": "#{url}"}]
  defp data(_), do: ""

  defp hook_name(_), do: "PhoenixLiveViewDropzone"
end
