defmodule Panglao.Client.Cheapcdn.Base do
  defmodule Client do
    defmacro __using__(opts) do
      quote do
        use HTTPoison.Base

        @api Application.get_env(:panglao, :cheapcdn)[:api]
        @cdnenv unquote(opts[:host])

        def cdnenv, do: @cdnenv

        def process_url(path) do
          Path.join @cdnenv[:endpoint], path
        end

        def process_request_body(body) do
          case body do
            {:form, form} ->
              {:form, transform(form)}
            body ->
              body
          end
        end

        defp transform(payload) do
          for {k, v} <- payload, into: [], do: {:"#{k}", v}
        end

        def process_request_options(options) do
          Keyword.merge options, [recv_timeout: 15_000, timeout: 15_000]
        end

        def process_response_body(body) do
          case Poison.decode body do
            {:ok,    body}        -> body
            {:error, body}        -> body
            {:error, :invalid, 0} -> body
          end
        end

        ### apis

        def gateway(params) do
          opts = [
            hackney: [basic_auth: @cdnenv[:auth]],
            params: Keyword.merge(transform(params), [name: 1]),
          ]
          get @api[:gateway], [], opts
        end

        def info(key) do
          key = Base.encode64 key
          get Path.join(@api[:info], key)
        end

        def nodeinfo do
          get @api[:nodeinfo]
        end

        def abledisk do
          get @api[:abledisk]
        end

        def progress(key) do
          key = Base.encode64 Path.basename(Path.rootname(key))
          get Path.join(@api[:progress], key)
        end

        def download(key) do
          key = Base.encode64 key
          get Path.join(@api[:download], key)
        end

        defdelegate remote_upload(key), to: __MODULE__, as: :download

        def findfile(key) do
          key = Base.encode64 Path.basename(Path.rootname(key))
          get Path.join(@api[:findfile], key)
        end

        def removefile(key) do
          key = Base.encode64 key
          get Path.join(@api[:removefile], key)
        end

        def extractors do
          get @api[:extractors]
        end
        def extractors! do
          case extractors() do
            {:ok, body} ->
              body
            {:error, error} ->
              raise error
          end
        end

        defoverridable Module.definitions_in(__MODULE__)
      end
    end
  end

  defmacro __using__(_) do
    quote do
      @hosts Enum.with_index(
        Application.get_env(:panglao, :cheapcdn)[:host], 1
      )

      Enum.each @hosts, fn {host, num} ->
        defmodule Module.concat(__MODULE__, "Client#{num}") do
          use Client, host: host
        end
      end

      @clients Enum.map @hosts, fn {_, num} ->
        Module.concat(__MODULE__, "Client#{num}")
      end

      def clients do
        @clients
      end

      def random_choice do
        Enum.random @clients
      end

      def weighted_choice do
        Enum.random @clients
      end

      def better_choice do
        Enum.random @clients
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end

end
