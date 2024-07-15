defmodule LivePremier.Screen do
  @moduledoc """
  The functions for interacting with the Screen commands
  """
  use LivePremier

  alias LivePremier.Screen.Info
  alias LivePremier.Screen.LayerInfo
  alias LivePremier.Screen.LayerStatus

  @doc """
  Get the status of a given id. The id has to be a number between 1 and 24
  """
  @spec info(LivePremier.t(), integer()) ::
          {:ok, Info.t()} | {:error, Error.t()}
  def info(%LivePremier{} = live_premier, id) when id in 1..24 do
    with {:ok, body} <- get_request(live_premier, "/screens/#{id}") do
      Info.new(body)
    end
  end

  def info(%LivePremier{}, id) do
    {:error, %Error{message: "ID can only be a number between 1 and 24, received #{inspect(id)}"}}
  end

  @doc """
  Loads the specified memory in the screen

  Options:

  - `memory_id` - the memory index (from 1 to 1000), required
  - `target` - the destination (“program” or “preview”). Optional, Default is “preview”
  """
  @spec load_memory(LivePremier.t(), integer(), keyword()) :: :ok | {:error, Error.t()}
  def load_memory(%LivePremier{} = live_premier, id, opts) when id in 1..24 do
    with {:ok, %{memory_id: memory_id, target: target}} <- validate_load_memory(opts) do
      post_request(live_premier, "/screens/#{id}/load-memory", %{
        memoryId: memory_id,
        target: target
      })
    end
  end

  def load_memory(%LivePremier{}, id, _) do
    {:error, %Error{message: "ID can only be a number between 1 and 24, received #{inspect(id)}"}}
  end

  @doc """
  Recalling a master preset from memory

  Options:

  - `memory_id` - the memory index (from 1 to 500), required
  - `target` - the destination (“program” or “preview”). Optional, Default is “preview”
  """
  @spec load_master_memory(LivePremier.t(), keyword()) :: :ok | {:error, Error.t()}
  def load_master_memory(%LivePremier{} = live_premier, opts) do
    with {:ok, %{memory_id: memory_id, target: target}} <- validate_load_memory(opts, 500) do
      post_request(live_premier, "/screens/load-master-memory", %{
        memoryId: memory_id,
        target: target
      })
    end
  end

  defp validate_load_memory(opts, max_memory_slots \\ 1000) do
    types = %{memory_id: :integer, target: :string}
    params = Enum.into(opts, %{})

    {%{target: "preview"}, types}
    |> cast(params, Map.keys(types))
    |> validate_required([:memory_id])
    |> validate_number(:memory_id,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: max_memory_slots
    )
    |> validate_inclusion(:target, ["preview", "program"])
    |> apply_action(:validate)
    |> handle_validate()
  end

  @doc """
  Reading a layer information
  """
  @spec layer_info(LivePremier.t(), integer(), integer()) ::
          {:ok, LayerInfo.t()} | {:error, Error.t()}
  def layer_info(%LivePremier{} = live_premier, screen_id, layer_id)
      when screen_id in 1..24 and layer_id in 1..128 do
    with {:ok, body} <- get_request(live_premier, "/screens/#{screen_id}/layers/#{layer_id}") do
      LayerInfo.new(body)
    end
  end

  def layer_info(%LivePremier{}, screen_id, layer_id) do
    cond do
      screen_id not in 1..24 ->
        {:error,
         %Error{
           message:
             "Screen ID can only be a number between 1 and 24, received #{inspect(screen_id)}"
         }}

      layer_id not in 1..128 ->
        {:error,
         %Error{
           message:
             "Layer ID can only be a number between 1 and 128, received #{inspect(layer_id)}"
         }}
    end
  end

  @doc """
  Reading a layer status

  ## Example

    > LivePremier.new("http://localhost:3000") |> LivePremier.layer_status(2, 3, :preview)
    %LivePremier.LayerStatus{}

  """
  @spec layer_status(LivePremier.t(), integer(), integer(), String.t()) ::
          {:ok, LayerStatus.t()} | {:error, Error.t()}
  def layer_status(%LivePremier{} = live_premier, screen_id, layer_id, target)
      when screen_id in 1..24 and layer_id in 1..128 and target in [:preview, :program] do
    with {:ok, body} <-
           get_request(live_premier, "/screens/#{screen_id}/layers/#{layer_id}/presets/#{target}") do
      LayerStatus.new(body)
    end
  end

  def layer_status(%LivePremier{}, screen_id, layer_id, target) do
    cond do
      screen_id not in 1..24 ->
        {:error,
         %Error{
           message: "Screen ID can only be a number between 1 and 24, got #{inspect(screen_id)}"
         }}

      layer_id not in 1..128 ->
        {:error,
         %Error{
           message: "Layer ID can only be a number between 1 and 128, got #{inspect(layer_id)}"
         }}

      target not in [:preview, :program] ->
        {:error,
         %Error{
           message: "Target can only be \"preview\" or \"program\", got #{inspect(layer_id)}"
         }}
    end
  end
end
