import Config

config :witai, http_client: HTTPoison
config :witai, token: System.get_env("WITAI_TOKEN")
