defmodule Witai.Client do
    require Logger

    @typedoc """
    Request_body can be a map or a list
    """
    @type request_body :: map | list

    @long_timeout 10000

    defguard is_request_body(body) when is_map(body) or is_list(body)

    @spec get(binary) :: map | list | binary
    def get(url) when is_binary(url) do
        %{body: body, status_code: code} = get_http_client().get!(url, get_default_headers())
        decode_body(body, code)
    end

    @spec post(binary, map | list) :: map | list
    def post(url, req_body) when is_binary(url) and is_request_body(req_body) do
        {:ok, req_body} = JSON.encode(req_body)
        %{body: body, status_code: code} = get_http_client().post!(url, req_body, get_default_headers())
        decode_body(body, code)
    end

    @spec delete(binary) :: :ok | :fail
    def delete(url) when is_binary(url) do
        %{body: _body, status_code: code} = get_http_client().delete!(url, get_default_headers(), recv_timeout: @long_timeout)
        case code do
            200 -> :ok
            _ -> :fail
        end
    end

    @spec delete(binary, list | map) :: :ok | :fail
    def delete(url, req_body) when is_binary(url) and is_request_body(req_body) do
        {:ok, req_body} = JSON.encode(req_body)
        %{body: _body, status_code: code} = get_http_client().request!(:delete, url, req_body, get_default_headers(), recv_timeout: @long_timeout)
        case code do
            200 -> :ok
            _ -> :fail
        end
    end

    @spec put(binary, map) :: :ok | :fail
    def put(url, req_body) when is_binary(url) and is_map(req_body) do
        {:ok, body} = JSON.encode(req_body)
        %{body: _body, status_code: code} = get_http_client().put!(url, body, get_default_headers(), recv_timeout: @long_timeout)
        case code do
            200 -> :ok
            _ -> :fail
        end
    end

    defp get_default_headers() do
        ["Authorization": "Bearer #{ get_token() }", "Content-Type": "application/json"]
    end

    def decode_body(body, 200) do
        JSON.decode! body
    end

    def decode_body(body, code) do
        IO.inspect("code #{ code }: failed because #{ JSON.encode!(body) }")
        :fail
    end

    def encode_message(term) when is_binary(term) do
        URI.encode(term)
    end

    defp get_token() do
        Application.fetch_env!(:witai, :token)
    end

    defp get_http_client() do
        Application.fetch_env!(:witai, :http_client)
    end
end
