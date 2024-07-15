defmodule LivePremier.Schema do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import LivePremier.Helper

      @doc """
      Creates a new changeset for #{__MODULE__ |> to_string() |> String.split(".") |> List.last()}
      """
      @spec changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
      def changeset(schema, params) do
        schema
        |> cast(params, fields())
        |> apply_cast_embeds(embeds())
      end

      @doc """
      Creates a new stuct for #{__MODULE__ |> to_string() |> String.split(".") |> List.last()}
      """
      @spec new(map()) :: {:ok, __MODULE__.t()} | {:error, LivePremier.Error.t()}
      def new(params) do
        __MODULE__
        |> struct(%{})
        |> changeset(params)
        |> apply_action(:new)
        |> handle_validate()
      end

      defp apply_cast_embeds(changeset, embeds) do
        Enum.reduce(embeds, changeset, fn embed, changeset_acc ->
          cast_embed(changeset_acc, embed)
        end)
      end

      defp fields do
        __MODULE__.__changeset__()
        |> Map.filter(fn
          {_, {:embed, _}} -> false
          {key, _} -> true
        end)
        |> Map.keys()
      end

      defp embeds do
        __MODULE__.__changeset__()
        |> Map.filter(fn
          {_, {:embed, _}} -> true
          {key, _} -> false
        end)
        |> Map.keys()
      end

      defoverridable changeset: 2
    end
  end
end
