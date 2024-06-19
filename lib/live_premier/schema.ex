defmodule LivePremier.Schema do
  @moduledoc false

  defmacro __using__(opts) do
    fields = Keyword.get(opts, :fields, [])
    embeds = Keyword.get(opts, :embeds, [])

    quote do
      use Ecto.Schema
      import Ecto.Changeset

      def changeset(schema, params) do
        schema
        |> cast(params, unquote(fields))
        |> apply_cast_embeds(unquote(embeds))
      end

      def new(params) do
        __MODULE__
        |> struct(%{})
        |> changeset(params)
        |> apply_changes()
      end

      defp apply_cast_embeds(changeset, embeds) do
        Enum.reduce(embeds, changeset, fn embed, changeset_acc ->
          cast_embed(changeset_acc, embed)
        end)
      end
    end
  end
end
