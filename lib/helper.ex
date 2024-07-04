defmodule LivePremier.Helper do
  alias LivePremier.Error

  @moduledoc false
  def handle_response({:ok, %Req.Response{body: ""}}) do
    :ok
  end

  def handle_response({:ok, %Req.Response{body: body}}) do
    {:ok, body}
  end

  def handle_response({:error, %Req.Response{body: body, status: status} = resp}) do
    {:error, %Error{code: status, message: body, raw: resp}}
  end

  def handle_response({:error, %Req.TransportError{reason: reason}} = resp) do
    {:error, %Error{message: reason, raw: resp}}
  end

  def handle_validate({:ok, params_or_struct}) do
    {:ok, params_or_struct}
  end

  def handle_validate({:error, %Ecto.Changeset{} = changeset}) do
    {:error, %Error{message: translate_changeset_errors(changeset), raw: changeset}}
  end

  # INFO: commented out to prevent compiler warnings
  # def translate_errors(errors, field) when is_list(errors) do
  #   for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  # end

  def translate_changeset_errors(changeset) do
    Enum.map_join(changeset, "\n", fn {key, value} -> "#{key} #{translate_error(value)}" end)
  end

  defp translate_error({msg, _opts}) do
    msg
  end
end
