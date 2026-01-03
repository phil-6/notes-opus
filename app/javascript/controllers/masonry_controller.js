import { Controller } from "@hotwired/stimulus"

// Controller to handle masonry layout reflow when content changes
export default class extends Controller {
  connect() {
    // Listen for turbo stream renders to trigger reflow
    document.addEventListener("turbo:before-stream-render", this.handleStreamRender.bind(this))
  }

  disconnect() {
    document.removeEventListener("turbo:before-stream-render", this.handleStreamRender.bind(this))
  }

  handleStreamRender(event) {
    // After turbo stream renders, trigger a reflow of masonry grids
    requestAnimationFrame(() => {
      this.reflow()
    })
  }

  reflow() {
    // Force reflow by reading and writing to the DOM
    const grids = document.querySelectorAll(".masonry-grid")
    grids.forEach(grid => {
      // Read offsetHeight to force style calculation
      void grid.offsetHeight
    })
  }
}

