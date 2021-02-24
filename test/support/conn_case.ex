defmodule CxsStarterWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use CxsStarterWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import CxsStarterWeb.ConnCase

      alias CxsStarterWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint CxsStarterWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(CxsStarter.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(CxsStarter.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_sign_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  @yesterday 86400

  def register_and_sign_in_user(%{conn: conn}) do
    confirmed_at =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(-@yesterday)
      |> NaiveDateTime.truncate(:second)

    user = CxsStarter.AccountsFactory.user_factory(%{confirmed_at: confirmed_at})

    %{conn: sign_in_user(conn, user), user: user}
  end

  @doc """
  Sign the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  def sign_in_user(conn, user) do
    token = CxsStarter.Accounts.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end
end
