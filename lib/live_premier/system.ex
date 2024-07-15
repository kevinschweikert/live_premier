defmodule LivePremier.System do
  use LivePremier
  alias LivePremier.System.Info

  @moduledoc """
  The function for the System commands
  """

  @doc """
  Returns a LivePremier.System struct from the LivePremier device.
  """

  @spec info(LivePremier.t()) :: {:ok, Info.t()} | {:error, Error.t()}
  def info(%LivePremier{} = live_premier) do
    with {:ok, body} <- get_request(live_premier, "/system") do
      Info.new(body)
    end
  end

  @doc """
  Reboots the LivePremier device
  """

  @spec reboot(LivePremier.t()) :: :ok | {:error, Error.t()}
  def reboot(%LivePremier{} = live_premier) do
    post_request(live_premier, "/system/reboot")
  end

  @doc """
  Shuts down the LivePremier device

  Options:

  - `:enable_wake_on_lan` - true to shut down the system with the Wakeon-LAN (WoL) feature enabled, false to shut down the system without enabling the Wakeon-LAN feature (default value is false)
  """

  @spec shutdown(LivePremier.t(), [{:enable_wake_on_lan, boolean()}]) :: :ok | {:error, Error.t()}
  def shutdown(%LivePremier{} = live_premier, opts \\ []) do
    with {:ok, %{enable_wake_on_lan: wol}} <- validate_shutdown(opts) do
      post_request(live_premier, "/system/shutdown", %{enableWakeOnLan: wol})
    end
  end

  defp validate_shutdown(opts) do
    types = %{enable_wake_on_lan: :boolean}
    params = Enum.into(opts, %{})

    {%{enable_wake_on_lan: false}, types}
    |> cast(params, Map.keys(types))
    |> apply_action(:validate)
    |> handle_validate()
  end
end
