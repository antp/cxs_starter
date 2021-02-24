defmodule CxsStarterWeb.UserSettings.Profile.DeleteAccountModal do
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
      |> assign(changeset: Accounts.change_delete_account(assigns.current_user))

    {:ok, socket}
  end

  @impl true
  def handle_event("delete-account", params, socket) do
    %{"current_password" => password} = params

    socket =
      case Accounts.delete_account(socket.assigns.current_user, password) do
        {:ok, _deleted_user} ->
          socket
          |> put_flash(:error, "Your account has been deleted!")
          |> redirect(to: Routes.page_path(socket, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          assign(socket, changeset: changeset)
      end

    {:noreply, socket}
  end
end
