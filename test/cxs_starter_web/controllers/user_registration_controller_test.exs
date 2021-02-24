defmodule CxsStarterWeb.UserRegistrationControllerTest do
  use CxsStarterWeb.ConnCase, async: true

  import CxsStarter.AccountsFactory

  describe "GET /users/register" do
    @tag :unit
    test "renders registration page", %{conn: conn} do
      conn = get(conn, Routes.user_registration_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "Register"
      assert response =~ "Sign in</a>"
      assert response =~ "Register</a>"
    end

    @tag :unit
    test "redirects if already logged in", %{conn: conn} do
      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      user = user_factory(%{confirmed_at: now})

      conn = conn |> sign_in_user(user) |> get(Routes.user_registration_path(conn, :new))

      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /users/register" do
    @tag :capture_log
    test "creates account and redirects to the signin", %{conn: conn} do
      email = unique_user_email()
      name = unique_user_name()

      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => %{"name" => name, "email" => email, "password" => valid_user_password()}
        })

      refute get_session(conn, :user_token)
      assert redirected_to(conn) =~ "/"

      # will not be signed in and assert the signed out menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      refute response =~ name
      refute response =~ "Settings</a>"
      refute response =~ "Sign out</a>"
      assert response =~ "Sign in</a>"
    end

    @tag :unit
    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => %{"email" => "with spaces", "password" => "too short"}
        })

      response = html_response(conn, 200)
      assert response =~ "Register"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "should be at least 12 character"
    end
  end
end
