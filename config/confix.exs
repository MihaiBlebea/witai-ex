use Mix.Config

config :witai,
    http_client: HTTPoison,
    token: "RSO37RX6O2NT3NCQWYF5CET4IJENJFCO"

import_config "config.#{ Mix.env() }.exs"
