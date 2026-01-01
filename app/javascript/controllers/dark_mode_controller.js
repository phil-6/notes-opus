import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"]

  toggle() {
    const isDark = this.checkboxTarget.checked
    document.documentElement.classList.toggle("dark", isDark)

    fetch("/users/preferences", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ dark_mode: isDark })
    })
  }
}
