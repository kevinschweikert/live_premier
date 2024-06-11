import Config

config :live_premier,
  live_premier_req_options: [
    plug: {Req.Test, LivePremierStub}
  ]
