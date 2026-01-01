import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["swatch", "button", "dropdown", "buttonColor"]
  static values = { open: Boolean }

  connect() {
    this.openValue = false
    this.handleClickOutside = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.handleClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside)
  }

  toggle(event) {
    event.stopPropagation()
    this.openValue = !this.openValue
  }

  openValueChanged() {
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.toggle("hidden", !this.openValue)
    }
  }

  select(event) {
    const selectedSwatch = event.target.closest("label")
    const color = selectedSwatch.dataset.color

    // Update all swatches
    this.swatchTargets.forEach(swatch => {
      swatch.classList.remove("selected")
    })
    selectedSwatch.classList.add("selected")

    // Update button color indicator
    if (this.hasButtonColorTarget) {
      // Remove all color classes and add the new one
      this.buttonColorTarget.className = this.buttonColorTarget.className
        .split(" ")
        .filter(c => !c.startsWith("color-swatch-"))
        .join(" ")
      this.buttonColorTarget.classList.add(`color-swatch-${color}`)
    }

    // Close dropdown
    this.openValue = false
  }

  handleClickOutside(event) {
    if (this.openValue && !this.element.contains(event.target)) {
      this.openValue = false
    }
  }
}
