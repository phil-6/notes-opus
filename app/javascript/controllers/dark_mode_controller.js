import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle() {
    const isDark = !document.documentElement.classList.contains("dark")
    document.documentElement.classList.toggle("dark", isDark)

    const toggleButton = this.element.querySelector("[role='switch']")
    if (toggleButton) {
      toggleButton.setAttribute("aria-checked", isDark)
    }

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
