defmodule LivePremier.System.Version do
  @moduledoc """
  Firmare Version struct

  Contains the digits for the major, minor and patch version. 
  Also includes a boolan if the firmware is a beta version or not.
  """

  use LivePremier.Schema

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
end
