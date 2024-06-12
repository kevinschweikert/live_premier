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

  if Mix.env() == :test do
    @req_options [plug: {Req.Test, LivePremierStub}]
  else
    @req_options []
  end

  defp request(%__MODULE__{host: host}, enpoint) do
    [base_url: Path.join(host, @api_path), url: enpoint]
    |> Keyword.merge(@req_options)
    |> Req.new()
  end

  @doc """
  Returns a LivePremier.System struct from the LivePremier device.
  """

  @spec system(__MODULE__.t()) :: {:ok, LivePremier.System.t()} | {:error, Error.t()}
  def system(%__MODULE__{} = live_premier) do
    with {:ok, %Req.Response{body: body, status: 200}} <-
           request(live_premier, "/system") |> Req.get() do
      {:ok,
       LivePremier.System.changeset(%LivePremier.System{}, body)
       |> Ecto.Changeset.apply_changes()}
    else
      {:error, %Req.Response{body: body, status: status}} = resp ->
        {:error, %Error{code: status, message: body, raw: resp}}
    end
  end

  @doc """
  Reboots the LivePremier device
  """

  @spec reboot(__MODULE__.t()) :: :ok | {:error, Error.t()}
  def reboot(%__MODULE__{} = live_premier) do
    with {:ok, %Req.Response{status: 200}} <-
           request(live_premier, "/system/reboot") |> Req.post() do
      :ok
    else
      {:error, %Req.Response{body: body, status: status}} = resp ->
        {:error, %Error{code: status, message: body, raw: resp}}
    end
  end

  @doc """
  Shuts down the LivePremier device

  Options:

  - `:enable_wake_on_lan` - true to shut down the system with the Wakeon-LAN (WoL) feature enabled, false to shut down the system without enabling the Wakeon-LAN feature (default value is false)
  """

  @spec shutdown(__MODULE__.t(), [{:enable_wake_on_lan, boolean()}]) :: :ok | {:error, Error.t()}
  def shutdown(%__MODULE__{} = live_premier, opts \\ []) do
    wol = Keyword.get(opts, :enable_wake_on_lan, false)

    with {:ok, %Req.Response{status: 200}} <-
           request(live_premier, "/system/shutdown") |> Req.post(json: %{enableWakeOnLan: wol}) do
      :ok
    else
      {:error, %Req.Response{body: body, status: status}} = resp ->
        {:error, %Error{code: status, message: body, raw: resp}}
    end
  end
end
