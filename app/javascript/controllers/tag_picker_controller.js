import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tag"]

  toggle(event) {
    const label = event.target.closest("label")
    if (event.target.checked) {
      label.classList.add("tag-toggle-active")
    } else {
      label.classList.remove("tag-toggle-active")
    }
  }
}
