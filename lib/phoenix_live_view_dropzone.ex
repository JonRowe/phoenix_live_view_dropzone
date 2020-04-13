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
      data-id="<%= data(assigns)[:id] %>"
      data-url="<%= data(assigns)[:url] %>"
      phx-update="ignore"
      phx-hook="<%= hook_name(assigns) %>"
    >
    </div>
    """
  end

  defp id(%{dom_id: dom_id}) when is_binary(dom_id), do: dom_id
  defp id(_), do: @default_name

  defp css_class(%{css_class: css_class}) when is_binary(css_class), do: css_class
  defp css_class(_), do: @default_name

  defp data(%{file_data: %{id: id, url: url}}), do: %{id: id, url: url}
  defp data(_), do: %{id: "", url: ""}

  defp hook_name(%{hook: name}) when is_binary(name), do: name
  defp hook_name(_), do: "PhoenixLiveViewDropzone"
end
