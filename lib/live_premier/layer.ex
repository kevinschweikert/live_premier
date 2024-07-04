defmodule LivePremier.Layer do
  use LivePremier.Schema

  @moduledoc """
  Layer Information struct

  - `capacity` - The layer capacity (from 0 to 8)  
  - `canUseMask` - true if the layer can use a mask, false if not
  """

  embedded_schema do
    field :capacity, :integer
    field :canUseMask, :boolean
  end
end
