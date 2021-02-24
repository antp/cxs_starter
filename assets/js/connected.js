export const ConnectionStatus = {
  mounted () {
    window.connected = true
  },
  disconnected () {
    window.connected = false
  },
  reconnected () {
    window.connected = true
  }
}