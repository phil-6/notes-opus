import { Controller } from "@hotwired/stimulus"
import * as Turbo from "@hotwired/turbo"

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
    this.formSubmitting = false

    // Listen for form submission to prevent autosave conflicts
    if (this.hasFormTarget) {
      this.formTarget.addEventListener("submit", this.handleFormSubmit.bind(this))
    }
  }

  handleFormSubmit(event) {
    // Mark that form is being submitted normally
    this.formSubmitting = true
    clearTimeout(this.timeout)

    // If we have a noteId, update the form action to use the correct URL
    if (this.noteIdValue) {
      const form = this.formTarget
      form.action = this.urlValue.replace(/\/notes$/, `/notes/${this.noteIdValue}`)
      // Change method to PATCH using hidden field
      let methodField = form.querySelector('input[name="_method"]')
      if (!methodField) {
        methodField = document.createElement("input")
        methodField.type = "hidden"
        methodField.name = "_method"
        form.appendChild(methodField)
      }
      methodField.value = "patch"
    }
  }

  save() {
    // Don't autosave if form is being submitted
    if (this.formSubmitting) return

    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.submitForm()
    }, 1000)
  }

  async submitForm() {
    if (!this.hasFormTarget || this.saving || this.formSubmitting) return

    this.saving = true
    const formData = new FormData(this.formTarget)
    const isNewNote = !this.noteIdValue
    const method = isNewNote ? "POST" : "PATCH"
    const url = isNewNote ? this.urlValue : this.urlValue.replace(/\/notes$/, `/notes/${this.noteIdValue}`)

    // Mark this as an autosave request so the server knows not to close the modal
    formData.append("autosave", "true")

    try {
      // For new notes, use turbo_stream to prepend the card to the UI
      // For updates, use JSON to avoid UI flickering
      const acceptHeader = isNewNote ? "text/vnd.turbo-stream.html" : "application/json"

      const response = await fetch(url, {
        method: method,
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": acceptHeader
        },
        body: formData
      })

      if (response.ok && isNewNote) {
        const contentType = response.headers.get("content-type")
        if (contentType && contentType.includes("turbo-stream")) {
          const html = await response.text()
          // Render the turbo stream to update the UI
          Turbo.renderStreamMessage(html)
          // Find the note ID from the rendered turbo frame
          const match = html.match(/data-note-id="(\d+)"/)
          if (match) {
            this.noteIdValue = match[1]
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
    if (this.hasFormTarget) {
      this.formTarget.removeEventListener("submit", this.handleFormSubmit.bind(this))
    }
  }
}
