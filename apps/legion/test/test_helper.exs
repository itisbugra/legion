ExUnit.start(exclude: [:external])

Ecto.Adapters.SQL.Sandbox.mode(Legion.Repo, :manual)

{:ok, _} = Application.ensure_all_started(:ex_machina)

