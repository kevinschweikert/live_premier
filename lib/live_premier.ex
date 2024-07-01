defmodule LivePremier do
  @moduledoc """
  Documentation for `LivePremier`.
  """

  alias LivePremier.Error

  @api_path "/api/tpp/v1"

  @type t() :: %__MODULE__{
          host: String.t()
        }

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

  @spec request(__MODULE__.t(), String.t()) :: Req.Request.t()
  defp request(%__MODULE__{host: host}, enpoint) do
    [base_url: Path.join(host, @api_path), url: enpoint, retry: false]
    |> Keyword.merge(@req_options)
    |> Req.new()
  end

  defp handle_default_errors({:error, %Req.Response{body: body, status: status} = resp}),
    do: {:error, %Error{code: status, message: body, raw: resp}}

  defp handle_default_errors({:error, %Req.TransportError{reason: reason}} = resp),
    do: {:error, %Error{message: reason, raw: resp}}

  defp handle_default_errors({:error, %Ecto.Changeset{} = changeset}),
    do: {:error, %Error{message: changeset.errors, raw: changeset}}

  @doc """
  Returns a LivePremier.System struct from the LivePremier device.
  """

  @spec system(__MODULE__.t()) :: {:ok, LivePremier.System.t()} | {:error, Error.t()}
  def system(%__MODULE__{} = live_premier) do
    with {:ok, %Req.Response{body: body, status: 200}} <-
           request(live_premier, "/system") |> Req.get(),
         {:ok, system} <- LivePremier.System.new(body) do
      {:ok, system}
    else
      error -> handle_default_errors(error)
    end
  end

  @doc """
  Reboots the LivePremier device
  """

  @spec reboot(__MODULE__.t()) :: :ok | {:error, Error.t()}
  def reboot(%__MODULE__{} = live_premier) do
    case request(live_premier, "/system/reboot") |> Req.post() do
      {:ok, %Req.Response{status: 200}} -> :ok
      error -> handle_default_errors(error)
    end
  end

  @doc """
  Shuts down the LivePremier device

  Options:

  - `:enable_wake_on_lan` - true to shut down the system with the Wakeon-LAN (WoL) feature enabled, false to shut down the system without enabling the Wakeon-LAN feature (default value is false)
  """

  @spec shutdown(__MODULE__.t(), [{:enable_wake_on_lan, boolean()}]) :: :ok | {:error, Error.t()}
  def shutdown(%__MODULE__{} = live_premier, opts \\ []) do
    opts = Keyword.validate!(opts, [:enable_wake_on_lan])
    wol = Keyword.get(opts, :enable_wake_on_lan, false)

    case request(live_premier, "/system/shutdown") |> Req.post(json: %{enableWakeOnLan: wol}) do
      {:ok, %Req.Response{status: 200}} -> :ok
      error -> handle_default_errors(error)
    end
  end

  @doc """
  Get the status of a given id. The id has to be a number between 1 and 24
  """
  @spec screen(__MODULE__.t(), integer()) :: {:ok, LivePremier.Screen.t()} | {:error, Error.t()}
  def screen(%__MODULE__{} = live_premier, id) when id in 1..24//1 do
    with {:ok, %Req.Response{body: body, status: 200}} <-
           request(live_premier, "/screens/#{id}") |> Req.get(),
         {:ok, screen} <- LivePremier.Screen.new(body) do
      {:ok, screen}
    else
      error -> handle_default_errors(error)
    end
  end

  @doc """
  Loads the specified memory in the screen

  Options:

  - `memory_id` - the memory index (from 1 to 1000), required
  - `target` - the destination (“program” or “preview”). Optional, Default is “preview”
  """
  @spec load_memory(__MODULE__.t(), integer(), keyword()) :: :ok | {:error, Error.t()}
  def load_memory(%__MODULE__{} = live_premier, id, opts) when id in 1..24//1 do
    opts = Keyword.validate!(opts, [:memory_id, :target])
    memory_id = Keyword.fetch!(opts, :memory_id)
    target = Keyword.get(opts, :target, "preview")

    case request(live_premier, "/screens/#{id}/load-memory")
         |> Req.post(json: %{memoryId: memory_id, target: target}) do
      {:ok, %Req.Response{status: 200}} -> :ok
      error -> handle_default_errors(error)
    end
  end
end
