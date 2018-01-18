use Mix.Config

config :quantum,
  timeout: :infinity

config :quantum, :panglao,
  cron: [
    # remote_perform: [
      # schedule: "* * * * *",
      # task: "Panglao.Tasks.Remote.perform",
      # args: []
    # ],
    remove_perform: [
      schedule: "10 * * * *",
      task: "Panglao.Cron.Caller.remove_perform",
      args: []
    ],
    remove_perform_disksize: [
      schedule: "*/5 * * * *",
      task: "Panglao.Cron.Caller.remove_perform_disksize",
      args: []
    ],
    cleanup_unses_files: [
      schedule: "*/5 * * * *",
      task: "Panglao.Cron.Caller.cleanup_unses_files",
      args: []
    ],
    touch_perform: [
      schedule: "* * * * *",
      task: "Panglao.Cron.Caller.touch_perform",
      args: []
    ],
    notify_perform: [
      schedule: "35 20 * * * ",  # UTC: 20:35
      task: "Panglao.Cron.Caller.notify_perform",
      args: []
    ]
  ]
