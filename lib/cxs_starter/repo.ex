defmodule CxsStarter.Repo do
  use Ecto.Repo,
    otp_app: :cxs_starter,
    adapter: Ecto.Adapters.Postgres
end
