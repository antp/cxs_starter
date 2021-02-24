defmodule CxsStarterWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  use Phoenix.HTML

  # alias CxsStarterWeb.Router.Helpers, as: Routes

  alias CxsStarter.Accounts

  @doc """
  Assign the `current_user` from the `user_token` in the socket assigns.

  If the `current_user` is set this is a noop.

  If the `user_token` is not passed the `current_user` is set to nil
  """
  def assign_defaults(%{"user_token" => user_token}, socket) do
    assign_new(socket, :current_user, fn ->
      Accounts.get_user_by_session_token(user_token)
    end)

    # if socket.assigns.current_user.confirmed_at do
    #   socket
    # else
    #   new_confirmation_link =
    #     link("Resend confirmation instructions",
    #       to: Routes.user_confirmation_path(socket, :new),
    #       class:
    #         "mx-2 p-2 text-sm text-blue-700 border border-gray-300 rounded-md hover:bg-gray-50"
    #     )

    #   socket
    #   |> redirect(to: Routes.page_path(socket, :index))
    #   |> put_flash(
    #     :error,
    #     ["Please confirm your email!", new_confirmation_link]
    #   )
    # end
  end

  def assign_defaults(_, socket) do
    assign(socket, :current_user, fn ->
      nil
    end)
  end

  @doc """
  Renders a component inside the `modal component.


  The passed opts requires a `:return_to` property to be set. This is the
  return url after the modal closes.

  All options are passed to the inner component.


  ## Examples

      <%%= live_modal @socket, FormComponent, opts
  """
  def live_modal(_socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    # modal_show = Keyword.fetch!(opts, :modal_show)

    modal_opts = [
      id: :modal,
      return_to: path,
      component: component,
      opts: opts
    ]

    # So...
    # socket above is marked as unused!
    # but used here!!!!
    # turns out live_component is a macro and it does not use the passed socket.
    # I presume it is passed for some API normalisation.
    live_component(socket, CxsStarterWeb.Live.Components.ModalDialog, modal_opts)
  end
end
