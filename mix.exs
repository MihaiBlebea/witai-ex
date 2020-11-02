defmodule Witai.MixProject do
    use Mix.Project

    def project do
        [
            app: :witai,
            version: "0.1.0",
            elixir: "~> 1.10",
            start_permanent: Mix.env() == :prod,
            deps: deps()
        ]
    end

    # Run "mix help compile.app" to learn about applications.
    def application do
        [
            extra_applications: [:logger],
            env: [
                http_client: HTTPoison,
                token: "RSO37RX6O2NT3NCQWYF5CET4IJENJFCO"
            ]
        ]
    end

    # Run "mix help deps" to learn about dependencies.
    defp deps do
        [
            {:httpoison, "~> 1.6", override: true},
            {:json, "~> 1.2"},
            {:ex_doc, "~> 0.22", only: :dev, runtime: false},
        ]
    end
end
