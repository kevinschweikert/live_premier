import Config

config :live_premier, live_premier_req_options: []

import_config "#{config_env()}.exs"
