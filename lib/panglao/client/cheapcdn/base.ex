defmodule Panglao.Client.Cheapcdn.Base do
  defmodule Client do
    defmacro __using__(opts) do
      quote do
        use HTTPoison.Base

        @api Application.get_env(:panglao, :cheapcdn)[:api]
        @cdnenv unquote(opts[:host])

        def cdnenv, do: @cdnenv
        def endpoint, do: @cdnenv[:endpoint]

        def process_url(path) do
          Path.join endpoint(), path
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
        def nodeinfo! do
          case nodeinfo() do
            {:ok, response} -> response
            {:error, error} -> raise error
          end
        end

        def abledisk do
          get @api[:abledisk]
        end
        def abledisk! do
          case abledisk() do
            {:ok, response} -> response
            {:error, error} -> raise error
          end
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
            {:ok, response} -> response
            {:error, error} -> raise error
          end
        end

        defoverridable Module.definitions_in(__MODULE__)
      end
    end
  end

  defmacro __using__(_) do
    quote do
      alias Panglao.Redis.Cheapcdn, as: State

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

      def gateway(id, params) do
        choice(id).gateway params
      end

      def info(id, key) do
        choice(id).info key
      end

      def nodeinfo do
        Enum.map @clients, & {&1, &1.nodeinfo!}
      end

      def progress(id, key) do
        choice(id).progress key
      end

      def download(id, key) do
        choice(id).download key
      end

      defdelegate remote_upload(id, key), to: __MODULE__, as: :download

      def findfile(id, key) do
        choice(id).findfile key
      end

      def removefile(id, key) do
        r = choice(id).removefile key
        State.del id
        r
      end

      def abledisk do
        Enum.map @clients, & {&1, &1.abledisk!}
      end

      def extractors! do
        choice().extractors!
      end

      def exists?(client, id) do
        client.endpoint == State.get(id)
      end

      def choice do
        Enum.random @clients
      end
      def choice(id) when is_binary(id) and byte_size(id) > 0 do
        endpoint = State.get id

        case Enum.filter(@clients, & &1.endpoint == endpoint) do
          [client] ->
            client
          _        ->
            client = choice()
            State.set id, client.endpoint
            client
        end
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end
end
