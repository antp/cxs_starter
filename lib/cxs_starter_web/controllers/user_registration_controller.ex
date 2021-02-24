defmodule CxsStarterWeb.UserRegistrationController do
  use CxsStarterWeb, :controller

  alias CxsStarter.Accounts
  alias CxsStarter.Accounts.User
  alias CxsStarterWeb.UserAuth

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        Accounts.deliver_user_confirmation_instructions(
          user,
          CxsStarterWeb.UrlProvider
        )

        conn
        # |> put_flash(:info, "User created successfully.")
        # |> UserAuth.log_in_user(user)
        |> put_flash(
          :info,
          "Nearly there! We sent you an email. Please confirm your email address to sign in."
        )
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
