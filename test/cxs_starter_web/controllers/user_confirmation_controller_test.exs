defmodule CxsStarterWeb.UserConfirmationControllerTest do
  use CxsStarterWeb.ConnCase, async: true
  use Bamboo.Test

  import CxsStarter.AccountsFactory
  import Mox

  alias CxsStarter.Accounts
  alias CxsStarter.Repo

  setup do
    %{user: user_factory()}
  end

  describe "GET /users/confirm" do
    @tag :unit
    test "renders the confirmation page", %{conn: conn} do
      conn = get(conn, Routes.user_confirmation_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "Resend confirmation instructions"
    end
  end

  describe "POST /users/confirm" do
    @tag :capture_log
    test "sends a new confirmation token", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_confirmation_path(conn, :create), %{
          "user" => %{"email" => user.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "confirm"
    end

    @tag :unit
    test "does not send confirmation token if account is confirmed", %{conn: conn, user: user} do
      Repo.update!(Accounts.User.confirm_changeset(user))

      conn =
        post(conn, Routes.user_confirmation_path(conn, :create), %{
          "user" => %{"email" => user.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      refute Repo.get_by(Accounts.UserToken, user_id: user.id)
    end

    @tag :unit
    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.user_confirmation_path(conn, :create), %{
          "user" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Accounts.UserToken) == []
    end
  end

  describe "GET /users/confirm/:token" do
    @tag :unit
    test "confirms the given token once", %{conn: conn, user: user} do
      CxsStarter.MockUrlProvider
      |> expect(:build_email_token, fn token ->
        "[TOKEN]#{token}[TOKEN]"
      end)
      |> expect(:base_url, fn ->
        "base_url"
      end)

      email =
        Accounts.deliver_user_confirmation_instructions(
          user,
          CxsStarter.MockUrlProvider
        )

      assert_delivered_email(email)

      html_token = extract_user_token(email.html_body)

      conn = get(conn, Routes.user_confirmation_path(conn, :confirm, html_token))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
      assert get_flash(conn, :info) =~ "Account confirmed successfully"
      assert Accounts.get_user!(user.id).confirmed_at
      refute get_session(conn, :user_token)
      assert Repo.all(Accounts.UserToken) == []

      # When not logged in
      conn = get(conn, Routes.user_confirmation_path(conn, :confirm, html_token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Account confirmation link is invalid or it has expired"

      # When logged in
      conn =
        build_conn()
        |> sign_in_user(user)
        |> get(Routes.user_confirmation_path(conn, :confirm, html_token))

      assert redirected_to(conn) == "/"
      refute get_flash(conn, :error)
    end

    @tag :unit
    test "does not confirm email with invalid token", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_confirmation_path(conn, :confirm, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Account confirmation link is invalid or it has expired"
      refute Accounts.get_user!(user.id).confirmed_at
    end
  end
end
