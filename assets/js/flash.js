export const Flash = {
  mounted () {
    window.flashHook = this
    this.closeTimeoutId = null
  },
  destroyed () {
    window.flashHook = null
  },
  flashOpened (key, timeout) {
    this.clearCloseFlashTimeout()
    if (key && timeout > 0) {
      this.closeTimeoutId = setTimeout(() => this.closeFlash(key), timeout)
    }
  },
  closeFlash (key) {
    this.clearCloseFlashTimeout()
    if (key) {
      this.pushEvent('lv:clear-flash', {
        key: key
      })
    }
  },
  clearCloseFlashTimeout () {
    if (this.closeTimeoutId != null) {
      clearTimeout(this.closeTimeoutId)
      this.closeTimeoutId = null
    }
  }
}





export const FlashNotice = {
  mounted() {
    this.handleEvent('flash-notice', ({kind, msg, timeout}) => {
      let actual_timeout = timeout === undefined ? 0 : timeout

      let event = new CustomEvent('flash-notice', {
        detail: {
          kind: kind,
          msg: msg,
          timeout: actual_timeout
        }
      })

      this.el.dispatchEvent(event)
    })
  }
}