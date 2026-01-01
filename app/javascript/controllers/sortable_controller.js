import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["handle"]
  static values = {
    url: String,
    section: String
  }

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      handle: ".drag-handle",
      ghostClass: "opacity-50",
      onEnd: this.onEnd.bind(this)
    })
  }

  onEnd(event) {
    const noteId = event.item.dataset.noteId
    const newPosition = event.newIndex

    const url = this.urlValue.replace(":id", noteId)

    fetch(url, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ position: newPosition })
    })
  }

  disconnect() {
    if (this.sortable) {
      this.sortable.destroy()
    }
  }
}
