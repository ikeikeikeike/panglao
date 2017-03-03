use Mix.Config

config :quantum, :panglao,
  cron: [
    remote_perform: [
      schedule: "* * * * *",
      task: "Panglao.Builders.Remote.perform",
      args: []
    ]
  ]
