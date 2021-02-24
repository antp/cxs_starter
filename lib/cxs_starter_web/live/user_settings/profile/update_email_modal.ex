defmodule CxsStarterWeb.UserSettings.Profile.UpdateEmailModal do
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
      |> assign(changeset: Accounts.change_user_email(assigns.current_user))

    {:ok, socket}
  end

  @impl true
  def handle_event("update-email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    socket =
      case Accounts.apply_user_email(
             socket.assigns.current_user,
             password,
             user_params
           ) do
        {:ok, updated_user} ->
          Accounts.deliver_update_email_instructions(
            updated_user,
            socket.assigns.current_user.email,
            CxsStarterWeb.UrlProvider
          )

          socket
          |> push_event("modal-close", %{})
          |> push_event("flash-notice", %{
            kind: :info,
            msg: "A link to confirm your email change has been sent to the new address.",
            timeout: 10000
          })

        {:error, %Ecto.Changeset{} = changeset} ->
          assign(socket, changeset: changeset)
      end

    {:noreply, socket}
  end
end
