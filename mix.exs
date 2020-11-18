defmodule Witai.MixProject do
    use Mix.Project

    def project do
        [
            app: :witai,
            version: "0.1.2",
            elixir: "~> 1.10",
            start_permanent: Mix.env() == :prod,
            description: description(),
            elixirc_paths: elixirc_paths(Mix.env),
            package: package(),
            deps: deps()
        ]
    end

    defp elixirc_paths(:test), do: ["lib", "test/mocks"]
    defp elixirc_paths(_), do: ["lib"]

    # Run "mix help compaile.app" to learn about applications.
    def application do
        [
            extra_applications: [:logger],
            env: [ http_client: HTTPoison ]
        ]
    end

    # Run "mix help deps" to learn about dependencies.
    defp deps do
        [
            {:httpoison, "~> 1.6"},
            {:json, "~> 1.2"},
            {:ex_doc, "~> 0.22", only: :dev, runtime: false},
        ]
    end

    defp description do
        """
        Elixir library to interact with Facebook's Witai API.
        """
    end

    defp package do
        [
            files: ["lib", "mix.exs", "README*", "LICENSE*"],
            maintainers: ["Mihai Blebea"],
            licenses: ["MIT"],
            links: %{"GitHub" => "https://github.com/MihaiBlebea/witai-ex"}
        ]
    end
end
