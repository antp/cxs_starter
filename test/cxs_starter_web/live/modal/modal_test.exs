defmodule CxsStarterWeb.ModalTest do
  use CxsStarterWeb.ConnCase, async: true
  use Bamboo.Test

  import Phoenix.LiveViewTest

  setup :register_and_sign_in_user

  @tag :unit
  test "will display and close the modal", %{conn: conn} do
    path = Routes.user_profile_path(conn, :profile)

    {:ok, view, _html} = live(conn, path)
    assert render(view) =~ "id=\"user-settings\""

    element(view, "#update-name")
    |> render_click()

    assert element(view, "#update-name-form")
           |> has_element?()

    assert element(view, "#modal")
           |> has_element?()

    element(view, "#modal")
    |> render_hook("modal-closed", %{})
  end
end
