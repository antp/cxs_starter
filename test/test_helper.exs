Mox.defmock(CxsStarter.MockUrlProvider, for: CxsStarter.UrlProvider)

Faker.start()
Elogram.start([])

ExUnit.start(exclude: [:pending, :external])

Ecto.Adapters.SQL.Sandbox.mode(CxsStarter.Repo, :manual)
