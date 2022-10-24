defmodule Kadena.Chainweb.Client.Default do
  @moduledoc """
  Hackney HTTP client implementation.

  This implementation allows you to use your own JSON encoding library. The default is Jason.
  """

  @behaviour Kadena.Chainweb.Client.Spec

  @type status :: pos_integer()
  @type headers :: [{binary(), binary()}, ...]
  @type body :: binary()
  @type success_response :: {:ok, status(), headers(), body()}
  @type error_response :: {:error, status(), headers(), body()} | {:error, any()}
  @type client_response :: success_response() | error_response()
  @type parsed_response :: {:ok, map()} | {:error, Keyword.t()}

  @impl true
  def request(path, method, headers \\ [], body \\ "", opts \\ []) do
    options = http_options(opts)

    method
    |> http_client().request(path, headers, body, options)
    |> handle_response()
  end

  @spec handle_response(response :: client_response()) :: parsed_response()
  defp handle_response({:ok, status, _headers, body}) when status in 200..299 do
    decoded_body = json_library().decode!(body, keys: :atoms)
    {:ok, decoded_body}
  end

  defp handle_response({:ok, status, _headers, body}) when status in 400..599,
    do: {:error, [chainweb: body]}

  defp handle_response({:error, reason}), do: {:error, [network: reason]}

  @spec http_client() :: atom()
  defp http_client, do: Application.get_env(:kadena, :http_client, :hackney)

  @spec json_library() :: module()
  defp json_library, do: Application.get_env(:kadena, :json_library, Jason)

  @spec http_options(options :: Keyword.t()) :: Keyword.t()
  defp http_options(options) do
    default_options = [recv_timeout: 30_000, follow_redirect: true]
    override_options = Application.get_env(:kadena, :hackney_options, [])

    default_options
    |> Keyword.merge(override_options)
    |> Keyword.merge(options)
    |> (&[:with_body | &1]).()
  end
end
