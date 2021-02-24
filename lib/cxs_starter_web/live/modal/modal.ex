defmodule CxsStarterWeb.Live.Components.ModalDialog do
  use Phoenix.LiveComponent

  def render(assigns) do
    error_dialog = Keyword.get(assigns.opts, :error_dialog, false)
    border_colour = get_border_colour(error_dialog)

    ~L"""
    <div class="fixed inset-x-0 bottom-0 z-40 px-4 pb-6 sm:inset-0 sm:p-0 sm:flex sm:items-center sm:justify-center"
    id="<%= @id %>"
    phx-target="<%= @myself %>"
    phx-hook="Modal"
      x-data="{modalOpen: false}"
      x-init="() => {
        setTimeout(() => modalOpen = true, 0)
        $watch('modalOpen', isOpen => {
          if (!isOpen) {
            modalHook.modalClosing(300)
          }
        })
      }"
      x-on:modal-close="modalOpen = false"
      x-cloak>
      <div class="fixed inset-0 transition-opacity"
        phx-window-keydown="cancel-modal"
        phx-key="escape"
        phx-target="<%= @myself %>"
        phx-page-loading

        x-show="modalOpen"

        x-transition:enter="transition ease-out duration-300"
        x-transition:enter-start="opacity-0"
        x-transition:enter-end="opacity-100"
        x-transition:leave="transition ease-in duration-200"
        x-transition:leave-start="opacity-100"
        x-transition:leave-end="opacity-0"

        x-cloak>
        <div class="absolute inset-0 bg-gray-500 opacity-75"></div>
      </div>

      <div class="z-sky max-w-2xl px-4 pt-5 pb-4 overflow-hidden transition-all transform border <%= border_colour %> rounded-lg shadow-xl sm:w-full bg-gray-50" role="dialog" aria-modal="true"
        x-show="modalOpen"

        x-transition:enter="transition ease-out duration-300"
        x-transition:enter-start="opacity-0 translate-y-4 transform scale-95"
        x-transition:enter-end="opacity-100 translate-y-0 transform scale-100"
        x-transition:leave="transition ease-in duration-200"
        x-transition:leave-start="opacity-100 translate-y-0 transform scale-100"
        x-transition:leave-end="opacity-0 translate-y-4 transform scale-90"

        x-cloak>
        <%= live_component @socket, @component, @opts  %>
      </div>
      <template id="connection-status" phx-hook="ConnectionStatus"></template>
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("modal-closed", _params, socket) do
    socket = push_patch(socket, to: socket.assigns.return_to)

    {:noreply, socket}
  end

  defp get_border_colour(true) do
    "border-red-500"
  end

  defp get_border_colour(_) do
    "border-blue-500"
  end
end
