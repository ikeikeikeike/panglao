use Mix.Config

config :quantum, :panglao,
  cron: [
    remote_perform: [
      schedule: "* * * * *",
      task: "Panglao.Builders.Remote.perform",
      args: []
    ],
    remove_perform: [
      schedule: "10 * * * *",
      task: "Panglao.Builders.Remove.perform",
      args: []
    ]
  ]
