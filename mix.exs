defmodule Panglao.Mixfile do
  use Mix.Project

  def project do
    [app: :panglao,
     version: version(),
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  defp version do
    v = "0.1.0"
    File.write! "VERSION", v
    v
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Panglao, []},
     applications: [
       :phoenix,
       :phoenix_pubsub,
       :phoenix_html,
       :cowboy,
       :logger,
       :gettext,
       :phoenix_ecto,
       :postgrex,

       :yamerl,

       :hackney,
       :poison,

       :chexes,
       :common_device_detector,
       :phoenix_html_simplified_helpers,

       :ex_aws,
       :arc,
       :arc_ecto,

       :ffmpex,
       :thumbnex,

       :exq,
     ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.2.1"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},

      {:poison, "~> 3.1", override: true},
      {:yamerl, "~> 0.4", override: true},

      {:arc, "~> 0.7", override: true},
      {:arc_ecto, "~> 0.5"},

      {:exq, "~> 0.8"},
      {:ffmpex, "~> 0.4"},
      {:thumbnex, "~> 0.2"},

      {:ex_aws, "~> 1.1"},
      {:hackney, "~> 1.6"},
      {:sweet_xml, "~> 0.6"},

      {:chexes, github: "ikeikeikeike/chexes"},
      {:common_device_detector, github: "ikeikeikeike/common_device_detector"},
      {:phoenix_html_simplified_helpers, "~> 1.1"},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": [
      "ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
