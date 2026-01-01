import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]
  static values = {
    url: String,
    method: { type: String, default: "post" }
  }

  connect() {
    this.timeout = null
  }

  save() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.submitForm()
    }, 1000)
  }

  submitForm() {
    if (!this.hasFormTarget) return

    const formData = new FormData(this.formTarget)

    fetch(this.urlValue, {
      method: this.methodValue.toUpperCase() === "POST" ? "POST" : "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: formData
    })
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
