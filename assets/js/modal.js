export const Modal = {
  mounted() {
    window.modalHook = this

    this.handleEvent('modal-close', () => {
      let event = new CustomEvent('modal-close', {})

      this.el.dispatchEvent(event)
    })
  },
  destroyed() {
    window.modalHook = null
  },
  modalClosing(leave_duration) {
    // Inform modal component when leave transition completes.
    setTimeout(() => {
      var selector = '#' + this.el.id
      if (document.querySelector(selector)) {
        this.pushEventTo(selector, 'modal-closed', {})
      }
    }, leave_duration);
  }
}