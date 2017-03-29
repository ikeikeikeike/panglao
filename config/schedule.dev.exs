use Mix.Config

config :quantum, :panglao,
  cron: [
    remote_perform: [
      schedule: "* * * * *",
      task: "Panglao.Tasks.Remote.perform",
      args: []
    ],
    remove_perform: [
      schedule: "10 * * * *",
      task: "Panglao.Tasks.Remove.perform",
      args: []
    ]
  ]
