use Mix.Config

config :quantum,
  timeout: :infinity

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
    ],
    cleanup_unses_files: [
      schedule: "*/5 * * * *",
      task: "Panglao.Tasks.Cleanup.unses_files",
      args: []
    ]
  ]
