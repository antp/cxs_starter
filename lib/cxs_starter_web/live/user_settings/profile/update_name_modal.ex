defmodule CxsStarterWeb.UserSettings.Profile.UpdateNameModal do
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
      |> assign(changeset: Accounts.change_user_name(assigns.current_user))

    {:ok, socket}
  end

  @impl true
  def handle_event("update-name", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    socket =
      case Accounts.update_user_name(socket.assigns.current_user, password, user_params) do
        {:ok, user} ->
          Process.send_after(self(), {:user_updated, user}, 500)

          socket
          |> push_event("modal-close", %{})
          |> push_event("flash-notice", %{
            kind: :info,
            msg: "Your name has been changed.",
            timeout: 10000
          })

        {:error, %Ecto.Changeset{} = changeset} ->
          assign(socket, changeset: changeset)
      end

    {:noreply, socket}
  end
end
