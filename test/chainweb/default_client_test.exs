defmodule Kadena.Chainweb.CannedHTTPClient do
  @moduledoc false

  alias Kadena.Test.Fixtures.Chainweb

  @spec request(
          method :: atom(),
          url :: String.t(),
          headers :: list(),
          body :: String.t(),
          opt :: list()
        ) :: {:ok, non_neg_integer(), list(), String.t()} | {:error, Keyword.t()}
  def request(method, url, headers \\ [], body \\ "", opt \\ [])
  def request(:post, _url, _headers, "", _opt), do: {:ok, 400, [], "not enough input"}
  def request(:post, _url, [], _body, _opt), do: {:ok, 400, [], ""}
  def request(:get, _url, _headers, _body, _opt), do: {:ok, 405, [], ""}

  def request(:post, _url, _headers, _body, [:with_body, follow_redirect: true, recv_timeout: 1]),
    do: {:error, :timeout}

  def request(:post, _url, _headers, _body, _opt) do
    json_body = Chainweb.fixture("200")
    {:ok, 200, [], json_body}
  end
end

defmodule Kadena.Chainweb.DefaultClientTest do
  use ExUnit.Case

  alias Kadena.Chainweb.{CannedHTTPClient, Client}

  setup do
    Application.put_env(:kadena, :http_client, CannedHTTPClient)

    on_exit(fn ->
      Application.delete_env(:kadena, :http_client)
    end)

    %{
      url: "https://api.testnet.chainweb.com/chainweb/0.0/testnet04/chain/0/pact/api/v1",
      header: [{"Content-Type", "application/json"}],
      body:
        "{\"cmd\":\"{\\\"meta\\\":{\\\"chainId\\\":\\\"\\\",\\\"creationTime\\\":0,\\\"gasLimit\\\":10,\\\"gasPrice\\\":0,\\\"sender\\\":\\\"\\\",\\\"ttl\\\":0},\\\"networkId\\\":null,\\\"nonce\\\":\\\"\\\\\\\"step01\\\\\\\"\\\",\\\"payload\\\":{\\\"cont\\\":null,\\\"exec\\\":{\\\"code\\\":\\\"(+ 2 3)\\\",\\\"data\\\":{\\\"accountsAdminKeyset\\\":[\\\"ba54b224d1924dd98403f5c751abdd10de6cd81b0121800bf7bdbdcfaec7388d\\\"]}}},\\\"signers\\\":[]}\",\"hash\":\"jr6N7jQ9nVH0A_gRxe3RfKxR7rHn-IG-GosWz6WnMXQ\",\"sigs\":[]}"
    }
  end

  describe "request/6" do
    test "success", %{url: url, header: header, body: body} do
      {:ok,
       %{
         result: %{
           status: "success",
           data: 5
         }
       }} = Client.request(url <> "/local", :post, header, body)
    end

    test "with an invalid body", %{url: url, header: header} do
      {:error, [chainweb: "not enough input"]} = Client.request(url <> "/local", :post, header)
    end

    test "without header", %{url: url, body: body} do
      {:error, [chainweb: ""]} = Client.request(url <> "/local", :post, [], body)
    end

    test "with an invalid method", %{url: url, header: header, body: body} do
      {:error, [chainweb: ""]} = Client.request(url <> "/local", :get, header, body)
    end

    test "timeout", %{url: url, header: header, body: body} do
      {:error, [network: :timeout]} =
        Client.request(url <> "/local", :post, header, body, recv_timeout: 1)
    end
  end
end
