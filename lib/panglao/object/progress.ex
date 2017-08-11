defmodule Panglao.Object.Progress do
  alias Panglao.{Client.Cheapcdn}
  alias Timex.Duration

  def get(%{url: _, remote: _} = o) do
    case o.remote && Cheapcdn.progress(o.url, o.remote) do
      {:ok, %{body: b}} when map_size(b) <= 0 ->
        fallback o
      {:ok, %{body: b}} ->
        parse_body b
      _ ->
        none()
    end
  end

  defp none do
    %{
      status: nil,
      eta: nil,
      speed: nil,
      percent: nil,
      total_bytes: nil,
    }
  end

  defp parse_body(b) do
    %{
      status: Map.get(b, "status", "finished"),
      eta: Map.get(b, "_eta_str"),
      speed: Map.get(b, "_speed_str"),
      percent: Map.get(b, "_percent_str"),
      total_bytes: Map.get(b, "_total_bytes_estimate_str", Map.get(b, "_total_bytes_str")),
    }
  end

  defp fallback(o) do
    case File.stat "#{o.remote}.part" do
      {:ok, %{size: size}} ->
        total   = 525.20
        speed   = 50.50
        current = Float.round(size / 1024 / 1024, 2)
        eta     = round((total - current) / (current / speed))

        %{
          "status" => "downloading",
          "eta" => Duration.from_seconds(eta) |> Duration.to_time! |> to_string,
          "percent" => "#{Float.round(current / total * 100, 2)}%",
          "speed" => "#{speed}KiB/s",
          "total_bytes" => "#{total}MiB",
        }
      _ ->
        none()
    end
  end

end
