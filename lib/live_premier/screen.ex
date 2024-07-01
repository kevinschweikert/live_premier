defmodule LivePremier.Screen do
  @moduledoc """
  Screen Information struct

  - `isEnabled` - true if the screen is enabled, false if not
  - `label` - the screen label
  """

  use LivePremier.Schema

  @type t() :: %__MODULE__{
          isEnabled: boolean(),
          label: String.t()
        }

  embedded_schema do
    field :isEnabled, :boolean
    field :label, :string
  end
end
