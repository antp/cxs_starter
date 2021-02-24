defmodule CxsStarterWeb.UserSettings.UserProfileLive do
  use CxsStarterWeb, :live_view

  alias CxsStarterWeb.Router.Helpers, as: Routes

  alias CxsStarter.Accounts

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign_defaults(session, socket)
      |> assign(title: "Profile")

    {:ok, socket, layout: {CxsStarterWeb.LayoutView, "profile_live.html"}}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket = apply_action(socket, socket.assigns.live_action, params)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:confirm_email, token}, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          push_patch(socket, to: Routes.user_profile_path(socket, :profile))
          |> push_event("flash-notice", %{
            kind: :info,
            msg: "Email changed successfully.",
            timeout: 10000
          })
          |> assign(current_user: Accounts.get_user!(socket.assigns.current_user.id))

        :error ->
          push_patch(socket, to: Routes.user_profile_path(socket, :profile))
          |> push_event("flash-notice", %{
            kind: :error,
            msg: "Email change link is invalid or it has expired.",
            timeout: 0
          })
      end

    {:noreply, socket}
  end

  def handle_info({:user_updated, new_user}, socket) do
    socket =
      socket
      |> push_event("user-changed", %{
        name: new_user.name,
        email: new_user.email
      })
      |> assign(current_user: new_user)

    {:noreply, socket}
  end

  defp apply_action(socket, :profile, _params) do
    socket
  end

  defp apply_action(socket, :delete, _params) do
    socket
    |> assign(modal: CxsStarterWeb.UserSettings.Profile.DeleteAccountModal)
  end

  defp apply_action(socket, :name_edit, _params) do
    socket
    |> assign(modal: CxsStarterWeb.UserSettings.Profile.UpdateNameModal)
  end

  defp apply_action(socket, :email_edit, _params) do
    socket
    |> assign(modal: CxsStarterWeb.UserSettings.Profile.UpdateEmailModal)
  end

  defp apply_action(socket, :password_edit, _params) do
    socket
    |> assign(modal: CxsStarterWeb.UserSettings.Profile.UpdatePasswordModal)
  end

  defp apply_action(socket, :confirm_email, %{"token" => token}) do
    send(self(), {:confirm_email, token})

    socket
  end
end
