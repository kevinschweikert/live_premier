defmodule LivePremier.System do
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{
          type: String.t(),
          label: String.t(),
          version: LivePremier.Version.t()
        }

  @primary_key false
  embedded_schema do
    field :type, :string
    field :label, :string
    embeds_one :version, LivePremier.Version
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:type, :label])
    |> cast_embed(:version)
  end
end
