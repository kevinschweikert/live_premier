defmodule LivePremier.Version do
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{
          major: integer(),
          minor: integer(),
          patch: integer(),
          beta: boolean()
        }

  @primary_key false
  embedded_schema do
    field :major, :integer
    field :minor, :integer
    field :patch, :integer
    field :beta, :boolean
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:major, :minor, :patch, :beta])
  end
end
