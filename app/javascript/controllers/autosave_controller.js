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

    try {
      const response = await fetch(url, {
        method: method,
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": "application/json"
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
    if (this.hasFormTarget) {
      this.formTarget.removeEventListener("submit", this.handleFormSubmit.bind(this))
    }
  }
}
