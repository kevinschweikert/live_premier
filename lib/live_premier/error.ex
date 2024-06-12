defmodule LivePremier.Error do
  @moduledoc """
  Encapsulates errors encountered during requests to the LivePremier API.
  """

  defexception [:message, :code, :raw]

  @type t :: %__MODULE__{
          message: String.t() | nil,
          code: integer() | nil,
          raw: term() | nil
        }

  @impl Exception
  def exception(opts),
    do: %__MODULE__{code: opts[:code], message: opts[:message], raw: opts[:raw]}
end
