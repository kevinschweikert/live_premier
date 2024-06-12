defmodule LivePremier.System do
  @moduledoc """
  System Information struct

  - `type` - the type of LivePremier device: ‘AQL RS alpha’, ‘AQL RS1’, ‘AQL RS2’, ‘AQL RS3’, ‘AQL RS4’, ‘AQL RS5’, ‘AQL RS6’, ‘AQL C’, ‘AQL C+’ or ‘AQL CMAX’
  - `label` - the device label
  - `version` - the Version struct for the current firmware version
  """

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
