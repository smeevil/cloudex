use Mix.Config

config :cloudex, :json_library, Jason

import_config "#{Mix.env()}.exs"
