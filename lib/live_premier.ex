defmodule LivePremier do
  @moduledoc """
  Documentation for `LivePremier`.
  """

  import Ecto.Changeset

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

  @spec request(__MODULE__.t(), String.t()) :: Req.Request.t()
  defp request(%__MODULE__{host: host}, enpoint) do
    [base_url: Path.join(host, @api_path), url: enpoint, retry: false]
    |> Keyword.merge(@req_options)
    |> Req.new()
  end

  @spec get_request(__MODULE__.t(), String.t()) :: response()
  defp get_request(%__MODULE__{} = live_premier, enpoint) do
    live_premier |> request(enpoint) |> Req.get() |> handle_response()
  end

  @spec post_request(__MODULE__.t(), String.t()) :: response()
  defp post_request(%__MODULE__{} = live_premier, enpoint) do
    live_premier |> request(enpoint) |> Req.post() |> handle_response()
  end

  @spec post_request(__MODULE__.t(), String.t(), map()) :: response()
  defp(post_request(%__MODULE__{} = live_premier, enpoint, json)) do
    live_premier |> request(enpoint) |> Req.post(json: json) |> handle_response()
  end

  defp handle_response({:ok, %Req.Response{body: ""}}) do
    :ok
  end

  defp handle_response({:ok, %Req.Response{body: body}}) do
    {:ok, body}
  end

  defp handle_response({:error, %Req.Response{body: body, status: status} = resp}) do
    {:error, %Error{code: status, message: body, raw: resp}}
  end

  defp handle_response({:error, %Req.TransportError{reason: reason}} = resp) do
    {:error, %Error{message: reason, raw: resp}}
  end

  defp handle_validate({:ok, params}) do
    {:ok, params}
  end

  defp handle_validate({:error, %Ecto.Changeset{} = changeset}) do
    {:error, %Error{message: translate_changeset_errors(changeset), raw: changeset}}
  end

  # INFO: commented out to prevent compiler warnings
  # defp translate_errors(errors, field) when is_list(errors) do
  #   for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  # end

  defp translate_changeset_errors(changeset) do
    Enum.map_join(changeset, "\n", fn {key, value} -> "#{key} #{translate_error(value)}" end)
  end

  defp translate_error({msg, _opts}) do
    msg
  end

  @doc """
  Returns a LivePremier.System struct from the LivePremier device.
  """

  @spec system(__MODULE__.t()) :: {:ok, LivePremier.System.t()} | {:error, Error.t()}
  def system(%__MODULE__{} = live_premier) do
    with {:ok, body} <- get_request(live_premier, "/system") do
      LivePremier.System.new(body)
    end
  end

  @doc """
  Reboots the LivePremier device
  """

  @spec reboot(__MODULE__.t()) :: :ok | {:error, Error.t()}
  def reboot(%__MODULE__{} = live_premier) do
    post_request(live_premier, "/system/reboot")
  end

  @doc """
  Shuts down the LivePremier device

  Options:

  - `:enable_wake_on_lan` - true to shut down the system with the Wakeon-LAN (WoL) feature enabled, false to shut down the system without enabling the Wakeon-LAN feature (default value is false)
  """

  @spec shutdown(__MODULE__.t(), [{:enable_wake_on_lan, boolean()}]) :: :ok | {:error, Error.t()}
  def shutdown(%__MODULE__{} = live_premier, opts \\ []) do
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

  @doc """
  Get the status of a given id. The id has to be a number between 1 and 24
  """
  @spec screen(__MODULE__.t(), integer()) :: {:ok, LivePremier.Screen.t()} | {:error, Error.t()}
  def screen(%__MODULE__{} = live_premier, id) when id in 1..24//1 do
    with {:ok, body} <- get_request(live_premier, "/screens/#{id}") do
      LivePremier.Screen.new(body)
    end
  end

  def screen(_, id) do
    {:error, %Error{message: "ID can only be a number between 1 and 24, received #{inspect(id)}"}}
  end

  @doc """
  Loads the specified memory in the screen

  Options:

  - `memory_id` - the memory index (from 1 to 1000), required
  - `target` - the destination (“program” or “preview”). Optional, Default is “preview”
  """
  @spec load_memory(__MODULE__.t(), integer(), keyword()) :: :ok | {:error, Error.t()}
  def load_memory(%__MODULE__{} = live_premier, id, opts) when id in 1..24//1 do
    with {:ok, %{memory_id: memory_id, target: target}} <- validate_load_memory(opts) do
      post_request(live_premier, "/screens/#{id}/load-memory", %{
        memoryId: memory_id,
        target: target
      })
    end
  end

  def load_memory(_, id, _) do
    {:error, %Error{message: "ID can only be a number between 1 and 24, received #{inspect(id)}"}}
  end

  defp validate_load_memory(opts) do
    types = %{memory_id: :integer, target: :string}
    params = Enum.into(opts, %{})

    {%{target: "preview"}, types}
    |> cast(params, Map.keys(types))
    |> validate_number(:memory_id, greater_than_or_equal_to: 0, less_than_or_equal_to: 1000)
    |> validate_required([:memory_id])
    |> apply_action(:validate)
    |> handle_validate()
  end
end
