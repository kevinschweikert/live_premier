defmodule LivePremier do
  @moduledoc """
  Documentation for `LivePremier`.
  """

  defmacro __using__(_opts) do
    quote do
      import LivePremier
      import Ecto.Changeset
      import LivePremier.Helper
      alias LivePremier.Error
    end
  end

  import LivePremier.Helper
  alias LivePremier.Error

  @api_path "/api/tpp/v1"

  @type t() :: %__MODULE__{
          host: String.t()
        }

  @type response() :: :ok | {:ok, binary() | map()} | {:error, Error.t()}

  defstruct(host: "http://localhost:3000")

  @doc """
  Creates a new LivePremier struct.

  ## Examples

      iex> LivePremier.new("https://example.com")
      %LivePremier{host: "https://example.com"}
  """

  def new(host) do
    %__MODULE__{host: host}
  end

  @doc false
  def api_path, do: @api_path

  if Mix.env() == :test do
    @req_options [plug: {Req.Test, LivePremierStub}]
  else
    @req_options []
  end

  @doc false
  @spec request(__MODULE__.t(), String.t()) :: Req.Request.t()
  def request(%__MODULE__{host: host}, enpoint) do
    [base_url: Path.join(host, @api_path), url: enpoint, retry: false]
    |> Keyword.merge(@req_options)
    |> Req.new()
  end

  @doc false
  @spec get_request(__MODULE__.t(), String.t()) :: response()
  def get_request(%__MODULE__{} = live_premier, enpoint) do
    live_premier |> request(enpoint) |> Req.get() |> handle_response()
  end

  @doc false
  @spec post_request(__MODULE__.t(), String.t()) :: response()
  def post_request(%__MODULE__{} = live_premier, enpoint) do
    live_premier |> request(enpoint) |> Req.post() |> handle_response()
  end

  @doc false
  @spec post_request(__MODULE__.t(), String.t(), map()) :: response()
  def(post_request(%__MODULE__{} = live_premier, enpoint, json)) do
    live_premier |> request(enpoint) |> Req.post(json: json) |> handle_response()
  end

  @doc module: :system
  defdelegate system_info(live_premier), to: LivePremier.System, as: :info
  @doc module: :system
  defdelegate shutdown(live_premier, opts \\ []), to: LivePremier.System
  @doc module: :system
  defdelegate reboot(live_premier), to: LivePremier.System
  @doc module: :screen
  defdelegate screen_info(live_premier, id), to: LivePremier.Screen, as: :info
  @doc module: :screen
  defdelegate load_memory(live_premier, id, opts), to: LivePremier.Screen
  @doc module: :screen
  defdelegate load_master_memory(live_premier, opts), to: LivePremier.Screen

  @doc module: :screen
  defdelegate layer_info(live_premier, screen_id, layer_id),
    to: LivePremier.Screen

  @doc module: :screen
  defdelegate layer_status(live_premier, screen_id, layer_id, target),
    to: LivePremier.Screen
end
