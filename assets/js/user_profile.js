export const UserProfile = {
  mounted() {
    this.handleEvent('user-changed', ({name, email}) => {
      let event = new CustomEvent('user-changed', {
        detail: {
          name: name,
          email: email
        }
      })

      window.dispatchEvent(event)
    })
  }
}
