import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  close() {
    this.element.remove()
    const modalFrame = document.getElementById("modal")
    if (modalFrame) {
      modalFrame.innerHTML = ""
    }
  }

  closeOnBackdrop(event) {
    if (event.target === this.element) {
      this.close()
    }
  }
}
