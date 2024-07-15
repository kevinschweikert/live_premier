defmodule LivePremier.Screen.LayerInfo do
  use LivePremier.Schema

  @moduledoc """
  Layer Information struct

  - `capacity` - The layer capacity (from 0 to 8)  
  - `canUseMask` - true if the layer can use a mask, false if not
  """
  @type t() :: %__MODULE__{
          capacity: integer(),
          canUseMask: boolean()
        }

  embedded_schema do
    field :capacity, :integer
    field :canUseMask, :boolean
  end
end
