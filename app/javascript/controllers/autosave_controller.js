import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]
  static values = {
    url: String,
    method: { type: String, default: "post" },
    noteId: { type: String, default: "" }
  }

  connect() {
    this.timeout = null
    this.saving = false
  }

  save() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.submitForm()
    }, 1000)
  }

  async submitForm() {
    if (!this.hasFormTarget || this.saving) return

    this.saving = true
    const formData = new FormData(this.formTarget)
    const isNewNote = !this.noteIdValue
    const method = isNewNote ? "POST" : "PATCH"
    const url = isNewNote ? this.urlValue : this.urlValue.replace(/\/notes$/, `/notes/${this.noteIdValue}`)

    try {
      const response = await fetch(url, {
        method: method,
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": "text/vnd.turbo-stream.html, application/json"
        },
        body: formData
      })

      if (response.ok && isNewNote) {
        const contentType = response.headers.get("content-type")
        if (contentType && contentType.includes("application/json")) {
          const data = await response.json()
          if (data.id) {
            this.noteIdValue = String(data.id)
          }
        }
      }
    } catch (error) {
      console.error("Autosave failed:", error)
    } finally {
      this.saving = false
    }
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
