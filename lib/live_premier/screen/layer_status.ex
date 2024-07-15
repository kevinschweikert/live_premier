defmodule LivePremier.Screen.LayerStatus do
  use LivePremier.Schema

  @moduledoc """
  Layer Status struct

  - `status` - the layer status: "off", "open", "close", "cross", "flying", "flying depth", "preempted", "mask", "out of capacity" 
  - `sourceType` - the type of source: "none", "color", "input", "image" or "screen"
  - `sourceId` - the source number
  """

  @type t() :: %__MODULE__{
          status: atom(),
          sourceType: atom(),
          sourceId: integer()
        }

  embedded_schema do
    field :status, Ecto.Enum,
      values: [
        :off,
        :open,
        :close,
        :cross,
        :flying,
        :flying_depth,
        :preempted,
        :mask,
        :out_of_capacity
      ]

    field :sourceType, Ecto.Enum, values: [:none, :color, :input, :image, :screen]
    field :sourceId, :integer
  end
end
