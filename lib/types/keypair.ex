defmodule Kadena.Types.KeyPair do
  @moduledoc """
  `KeyPair` struct definition.
  """
  alias Kadena.Types.OptionalCapsList

  @behaviour Kadena.Types.Spec

  @type key :: String.t()
  @type clist :: OptionalCapsList.t()
  @type arg_type :: atom()
  @type arg_value :: key() | clist()
  @type arg :: {arg_type(), arg_value()}
  @type arg_validation :: {:ok, arg_value()} | {:error, Keyword.t()}

  @type t :: %__MODULE__{pub_key: key(), secret_key: key(), clist: clist()}

  defstruct [:pub_key, :secret_key, :clist]

  @impl true
  def new(args) do
    pub_key_arg = Keyword.get(args, :pub_key)
    secret_key_arg = Keyword.get(args, :secret_key)
    clist_arg = Keyword.get(args, :clist)

    with {:ok, pub_key} <- validate_key({:pub_key, pub_key_arg}),
         {:ok, secret_key} <- validate_key({:secret_key, secret_key_arg}),
         {:ok, clist} <- validate_optional_caps_list({:clist, clist_arg}) do
      %__MODULE__{pub_key: pub_key, secret_key: secret_key, clist: clist}
    end
  end

  @spec validate_key(arg :: arg()) :: arg_validation()
  defp validate_key({_arg, key}) when is_binary(key) and byte_size(key) == 64, do: {:ok, key}
  defp validate_key({arg, _key}), do: {:error, [{arg, :invalid}]}

  @spec validate_optional_caps_list(arg :: arg()) :: arg_validation()
  defp validate_optional_caps_list({arg, clist}) do
    case OptionalCapsList.new(clist) do
      %OptionalCapsList{} = clist -> {:ok, clist}
      {:error, _reason} -> {:error, [{arg, :invalid}]}
    end
  end
end
