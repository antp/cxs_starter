defmodule CxsStarterWeb.UserSettings.Profile.UpdatePasswordModal do
  use CxsStarterWeb, :live_component

  use Phoenix.HTML
  alias CxsStarter.Accounts

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(changeset: Accounts.change_user_password(assigns.current_user))

    {:ok, socket}
  end

  @impl true
  def handle_event("update-password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    socket =
      case Accounts.update_user_password(socket.assigns.current_user, password, user_params) do
        {:ok, _updated_user} ->
          socket
          |> put_flash(:info, "Your password has been changed.")
          |> redirect(to: Routes.user_session_path(socket, :new))

        {:error, %Ecto.Changeset{} = changeset} ->
          assign(socket, changeset: changeset)
      end

    {:noreply, socket}
  end
end
