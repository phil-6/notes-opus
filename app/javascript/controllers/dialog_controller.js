import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.body.classList.add("overflow-hidden")
  }

  disconnect() {
    document.body.classList.remove("overflow-hidden")
  }

  close() {
    this.element.remove()
    const modalFrame = document.getElementById("modal")
    if (modalFrame) {
      modalFrame.innerHTML = ""
    }
  }

  stopPropagation(event) {
    event.stopPropagation()
  }
}
