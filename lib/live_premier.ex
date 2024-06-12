defmodule LivePremier do
  @moduledoc """
  Documentation for `LivePremier`.
  """

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

  @spec get_system(__MODULE__.t()) :: LivePremier.System.t()
  def get_system(%__MODULE__{} = live_premier) do
    %Req.Response{body: body, status: 200} = request(live_premier, "/system") |> Req.get!()

    LivePremier.System.changeset(%LivePremier.System{}, body)
    |> Ecto.Changeset.apply_changes()
  end

  @doc """
  Reboots the LivePremier device
  """

  @spec reboot(__MODULE__.t()) :: :ok
  def reboot(%__MODULE__{} = live_premier) do
    %Req.Response{status: 200} = request(live_premier, "/system/reboot") |> Req.post!()
    :ok
  end

  @doc """
  Shuts down the LivePremier device

  Options:

  - `:enable_wake_on_lan` - true to shut down the system with the Wakeon-LAN (WoL) feature enabled, false to shut down the system without enabling the Wakeon-LAN feature (default value is false)
  """

  @spec shutdown(__MODULE__.t(), Keyword.t()) :: :ok
  def shutdown(%__MODULE__{} = live_premier, opts \\ []) do
    wol = Keyword.get(opts, :enable_wake_on_lan, false)

    %Req.Response{status: 200} =
      request(live_premier, "/system/shutdown")
      |> Req.post!(
        json: %{
          enableWakeOnLan: wol
        }
      )

    :ok
  end
end
