defmodule PhoenixLiveViewDropzone.MixProject do
  use Mix.Project

  @version "0.0.5"

  def project do
    [
      app: :phoenix_live_view_dropzone,
      description: "A Phoenix LiveView compatible file dropzone.",
      elixir: "~> 1.10",
      version: @version,
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  def application, do: []

  defp deps do
    [
      {:ex_doc, "~> 0.21.3", only: :dev},
      {:jason, "~> 1.2.0", only: :test},
      {:phoenix_live_view, "~> 0.11.0"}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_ref: "v#{@version}",
      source_url: "https://github.com/JonRowe/phoenix_live_view_dropzone"
    ]
  end

  defp package do
    [
      maintainers: ["Jon Rowe"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/JonRowe/phoenix_live_view_dropzone"},
      files: ~w(lib priv) ++ ~w(mix.exs package.json README.md)
    ]
  end
end
