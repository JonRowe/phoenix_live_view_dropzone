defmodule PhoenixLiveViewDropzone.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_live_view_dropzone,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application, do: []

  defp deps do
    [
      {:jason, "~> 1.2.0", only: :test},
      {:phoenix_live_view, "~> 0.11.0"}
    ]
  end
end
