import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["swatch"]

  select(event) {
    this.swatchTargets.forEach(swatch => {
      swatch.classList.remove("selected")
    })
    event.target.closest("label").classList.add("selected")
  }
}
