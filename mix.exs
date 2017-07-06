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
    v = "0.2.52"
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
       :httpoison,

       :chexes,
       :common_device_detector,

       :ex_aws,
       :sweet_xml,
       :arc,

       :ffmpex,
       :thumbnex,

       :quantum,

       :exq,

       :csv,

       :comeonin,
       :ex_crypto,

       :bamboo,

       :observer_cli,

       :guardian, :guardian_db,
       :ueberauth, :ueberauth_identity,
       # :ueberauth_github, :ueberauth_facebook, :ueberauth_google, :ueberauth_twitter, :ueberauth_slack
     ],
      included_applications: [
        :phoenix_html_simplified_helpers,
        :timex,
        :timex_ecto,
        :crontab,
        :exsyslog,
        :syslog,
        :mogrify,

        :remote_ip,

        :rdtype,
        :elixir_make,
        :exactor,
        :sitemap,
        :xml_builder,
        :recaptcha,

        :cors_plug,
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
      {:hackney, "~> 1.8", override: true},
      {:httpoison, ">= 0.11.1", override: true},

      {:ex_aws, "~> 1.1"},
      {:arc, "~> 0.7"},
      {:sweet_xml, "~> 0.6"},

      {:exq, "~> 0.8"},
      {:ffmpex, "~> 0.4"},
      {:thumbnex, "~> 0.2"},

      {:quantum, ">= 1.9.0"},

      # Authenticate
      {:guardian, "~> 0.14"},
      {:guardian_db, "~> 0.8"},
      {:ueberauth, "~> 0.4"},
      {:ueberauth_identity, "~> 0.2"},
      # {:ueberauth_facebook, "~> 0.6"},
      # {:ueberauth_google, "~> 0.5"},
      # {:ueberauth_github, "~> 0.4"},
      # {:ueberauth_twitter, "~> 0.2"},
      # {:ueberauth_slack, "~> 0.4"},
      # end more: https://hex.pm/packages?search=ueberauth&sort=downloads

      {:csv, "~> 1.4"},

      {:cors_plug, "~> 1.2"},

      # Password hasher
      {:comeonin, "~> 3.0"},
      {:ex_crypto, "~> 0.3"},  # Need encrypt and decrypt.

      {:rdtype, "~> 0.5"},
      {:chexes, github: "ikeikeikeike/chexes"},
      {:common_device_detector, github: "ikeikeikeike/common_device_detector"},
      {:phoenix_html_simplified_helpers, "~> 1.1"},

      {:remote_ip, "~> 0.1"},
      {:recaptcha, "~> 2.1"},

      {:bamboo, "~> 0.8"},

      {:exsyslog, "~> 1.0"},
      {:sitemap, ">= 0.0.0"},
      {:distillery, "~> 1.3"},

      {:observer_cli, "~> 1.1.0"},

      {:credo, "~> 0.7", only: [:dev, :test]},
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
