defmodule CxsStarterWeb.UserProfileTest do
  use CxsStarterWeb.ConnCase, async: true
  use Bamboo.Test

  import Phoenix.LiveViewTest
  import CxsStarter.AccountsFactory
  import Mox

  alias CxsStarter.Accounts

  setup :register_and_sign_in_user

  @tag :unit
  test "/users/settings redirects to profile page", %{conn: conn} do
    {:error, {:redirect, redirect}} = live(conn, "/users/settings")

    assert Routes.user_profile_path(conn, :profile) == redirect.to
  end

  describe "GET /users/settings/profile" do
    setup %{conn: conn} do
      path = Routes.user_profile_path(conn, :profile)

      %{path: path}
    end

    @tag :unit
    test "renders profile page", %{conn: conn, path: path} do
      {:ok, view, _html} = live(conn, path)

      assert render(view) =~ "id=\"user-settings\""
    end

    # @tag :unit
    # test "redirects if user is not confirmed", %{conn: conn, path: path} do
    #   user = CxsStarter.AccountsFactory.user_factory(%{})
    #   conn = sign_in_user(conn, user)

    #   {:error, {:redirect, redirect}} = live(conn, path)

    #   assert Routes.page_path(conn, :index) == redirect.to
    # end

    @tag :unit
    test "redirects if user is not logged in", %{path: path} do
      conn = build_conn()

      {:error, {:redirect, redirect}} = live(conn, path)

      assert Routes.user_session_path(conn, :new) == redirect.to
    end

    @tag :unit
    test "will display the update name modal", %{conn: conn, path: path} do
      {:ok, view, _html} = live(conn, path)
      assert render(view) =~ "id=\"user-settings\""

      element(view, "#update-name")
      |> render_click()

      assert element(view, "#update-name-form")
             |> has_element?()
    end

    @tag :unit
    test "will display the update email modal", %{conn: conn, path: path} do
      {:ok, view, _html} = live(conn, path)
      assert render(view) =~ "id=\"user-settings\""

      element(view, "#update-email")
      |> render_click()

      assert element(view, "#update-email-form")
             |> has_element?()
    end

    @tag :unit
    test "will display the update password modal", %{conn: conn, path: path} do
      {:ok, view, _html} = live(conn, path)
      assert render(view) =~ "id=\"user-settings\""

      element(view, "#update-password")
      |> render_click()

      assert element(view, "#update-password-form")
             |> has_element?()
    end

    @tag :unit
    test "will display the delete account modal", %{conn: conn, path: path} do
      {:ok, view, _html} = live(conn, path)
      assert render(view) =~ "id=\"user-settings\""

      element(view, "#delete-account")
      |> render_click()

      assert element(view, "#delete-account-form")
             |> has_element?()
    end
  end

  describe "GET /users/settings/profile/name/edit" do
    setup %{conn: conn} do
      path = Routes.user_profile_path(conn, :name_edit)

      %{path: path}
    end

    @tag :unit
    test "modal has a cancel button", %{conn: conn, path: path} do
      {:ok, view, _html} = live(conn, path)

      assert render(view) =~ "id=\"user-settings\""

      assert element(view, "#update-name-cancel")
             |> has_element?()
    end

    @tag :unit
    test "will update the user name", %{conn: conn, path: path, user: user} do
      {:ok, view, _html} = live(conn, path)

      view
      |> form("#update-name-form", %{
        user: %{name: "New Name"},
        current_password: valid_user_password()
      })
      |> render_submit()

      assert_push_event(view, "modal-close", %{})

      assert_push_event(view, "flash-notice", %{
        kind: :info,
        msg: "Your name has been changed.",
        timeout: 10000
      })

      # this underscore tricks the compiler into not complaining about
      # email being unused!
      _email = user.email

      # small sleep - need to give the dialog a chance
      # to close nicely as the main view will update
      # the UI. This will remove the modal from the UI
      :timer.sleep(500)

      assert_push_event(view, "user-changed", %{
        name: "New Name",
        email: _email
      })

      {:ok, _view, html} = live(conn, Routes.user_profile_path(conn, :profile))
      assert html =~ "New Name"
    end

    @tag :unit
    test "does not update name on invalid data", %{conn: conn, path: path} do
      {:ok, view, _html} = live(conn, path)

      html =
        view
        |> form("#update-name-form", %{
          user: %{name: ""},
          current_password: "invalid password"
        })
        |> render_submit()

      assert html =~ "Name can&apos;t be blank"
      assert html =~ "Current password is not valid"
    end
  end

  describe "PUT /users/settings/profile/password/edit" do
    setup %{conn: conn} do
      path = Routes.user_profile_path(conn, :password_edit)

      %{path: path}
    end

    @tag :unit
    test "modal has a cancel button", %{conn: conn, path: path} do
      {:ok, view, _html} = live(conn, path)

      assert render(view) =~ "id=\"user-settings\""

      assert element(view, "#update-password-cancel")
             |> has_element?()
    end

    @tag :unit
    test "updates the user password and resets tokens", %{conn: conn, path: path, user: user} do
      {:ok, view, _html} = live(conn, path)

      assert element(view, "#update-password-form")
             |> has_element?()

      {:ok, redirected_conn} =
        view
        |> form("#update-password-form", %{
          user: %{password: "new valid password", password_confirmation: "new valid password"},
          current_password: valid_user_password()
        })
        |> render_submit()
        |> follow_redirect(conn, Routes.user_session_path(conn, :new))

      assert html_response(redirected_conn, 200)
      assert get_flash(redirected_conn, :info) =~ "Your password has been changed."

      {:error, {:redirect, redirect}} = live(conn, path)

      assert Routes.user_session_path(conn, :new) == redirect.to

      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    @tag :unit
    test "does not update password on invalid data", %{conn: conn, path: path} do
      {:ok, view, _html} = live(conn, path)

      assert element(view, "#update-password-form")
             |> has_element?()

      html =
        view
        |> form("#update-password-form", %{
          user: %{password: "", password_confirmation: "not matched"},
          current_password: "invalid password"
        })
        |> render_submit()

      assert html =~ "Password can&apos;t be blank"
      assert html =~ "Current password is not valid"
      assert html =~ "Password confirmation does not match password"
    end
  end

  describe "PUT /users/settings (change email form)" do
    setup %{conn: conn} do
      path = Routes.user_profile_path(conn, :email_edit)

      %{path: path}
    end

    @tag :unit
    test "modal has a cancel button", %{conn: conn, path: path} do
      {:ok, view, _html} = live(conn, path)

      assert render(view) =~ "id=\"user-settings\""

      assert element(view, "#update-email-cancel")
             |> has_element?()
    end

    @tag :unit
    test "updates the user email", %{conn: conn, user: user, path: path} do
      {:ok, view, _html} = live(conn, path)

      assert element(view, "#update-email-form")
             |> has_element?()

      new_email = Faker.Internet.email()

      view
      |> form("#update-email-form", %{
        user: %{email: new_email},
        current_password: valid_user_password()
      })
      |> render_submit()

      assert_push_event(view, "modal-close", %{})

      assert_push_event(view, "flash-notice", %{
        kind: :info,
        msg: "A link to confirm your email change has been sent to the new address.",
        timeout: 10000
      })

      assert Accounts.get_user_by_email(user.email)
    end

    @tag :unit
    test "does not update email on invalid data", %{conn: conn, path: path} do
      {:ok, view, _html} = live(conn, path)

      assert element(view, "#update-email-form")
             |> has_element?()

      html =
        view
        |> form("#update-email-form", %{
          user: %{email: ""},
          current_password: "invalid password"
        })
        |> render_submit()

      assert html =~ "Email can&apos;t be blank"
      assert html =~ "Current password is not valid"
    end
  end

  describe "GET /users/settings/confirm_email/:token" do
    setup %{user: user} do
      new_user_email = unique_user_email()

      CxsStarter.MockUrlProvider
      |> expect(:update_email_url, fn token ->
        "[TOKEN]#{token}[TOKEN]"
      end)
      |> expect(:base_url, fn ->
        "base_url"
      end)

      email =
        Accounts.deliver_update_email_instructions(
          %{user | email: new_user_email},
          user.email,
          CxsStarter.MockUrlProvider
        )

      assert_delivered_email(email)

      html_token = extract_user_token(email.html_body)

      %{token: html_token, email: new_user_email}
    end

    @tag :unit
    test "updates the user email once", %{conn: conn, user: user, token: token, email: email} do
      path = Routes.user_profile_path(conn, :confirm_email, token)

      {:ok, view, _html} = live(conn, path)

      assert_push_event(view, "flash-notice", %{
        kind: :info,
        msg: "Email changed successfully.",
        timeout: 10000
      })

      refute Accounts.get_user_by_email(user.email)
      assert Accounts.get_user_by_email(email)

      {:ok, view, _html} = live(conn, path)

      assert_push_event(view, "flash-notice", %{
        kind: :error,
        msg: "Email change link is invalid or it has expired.",
        timeout: 0
      })
    end

    @tag :unit
    test "does not update email with invalid token", %{conn: conn, user: user} do
      path = Routes.user_profile_path(conn, :confirm_email, "invalid-token")

      {:ok, view, _html} = live(conn, path)

      assert_push_event(view, "flash-notice", %{
        kind: :error,
        msg: "Email change link is invalid or it has expired.",
        timeout: 0
      })

      assert Accounts.get_user_by_email(user.email)
    end

    @tag :unit
    test "redirects if user is not logged in", %{token: token} do
      conn = build_conn()
      path = Routes.user_profile_path(conn, :confirm_email, token)

      {:error, {:redirect, redirect}} = live(conn, path)

      assert Routes.user_session_path(conn, :new) == redirect.to
    end
  end

  describe "GET /users/settings/delete" do
    setup %{conn: conn} do
      path = Routes.user_profile_path(conn, :delete)

      %{path: path}
    end

    @tag :unit
    test "will delete the account", %{conn: conn, path: path} do
      {:ok, view, _html} = live(conn, path)

      {:ok, redirected_conn} =
        view
        |> form("#delete-account-form", %{
          current_password: valid_user_password()
        })
        |> render_submit()
        |> follow_redirect(conn, Routes.page_path(conn, :index))

      assert html_response(redirected_conn, 200)
      assert get_flash(redirected_conn, :error) =~ "Your account has been deleted!"
    end

    @tag :unit
    test "does not delete on invalid data", %{conn: conn, path: path} do
      {:ok, view, _html} = live(conn, path)

      html =
        view
        |> form("#delete-account-form", %{
          current_password: "invalid"
        })
        |> render_submit()

      assert html =~ "Current password is not valid"
    end
  end
end
