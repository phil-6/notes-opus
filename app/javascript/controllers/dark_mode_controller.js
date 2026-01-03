import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle() {
    const isDark = !document.documentElement.classList.contains("dark")
    document.documentElement.classList.toggle("dark", isDark)

    const toggleButton = this.element.querySelector("[role='switch']")
    if (toggleButton) {
      toggleButton.setAttribute("aria-checked", isDark)
    }

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    const headers = {
      "Content-Type": "application/json"
    }
    if (csrfToken) {
      headers["X-CSRF-Token"] = csrfToken
    }

    fetch("/users/preferences", {
      method: "PATCH",
      headers: headers,
      body: JSON.stringify({ dark_mode: isDark })
    })
  }
}
