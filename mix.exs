defmodule PhoenixLiveViewDropzone.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_live_view_dropzone,
      description: "A Phoenix LiveView compatible file dropzone.",
      version: "0.0.1",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "PhoenixLiveViewDropzone",
      source_url: "https://github.com/JonRowe/phoenix_live_view_dropzone",
      package: [
        licenses: ["MIT"],
        links: %{}
      ],
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
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
end
