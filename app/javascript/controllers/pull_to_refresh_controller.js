import { Controller } from "@hotwired/stimulus";

// Pull-to-refresh for the mobile PWA. Only active on touch devices.
// Attach to the scrollable main element. Renders a spinner that
// drops down as the user pulls past the threshold; release triggers
// a Turbo.visit to refresh the current page.
export default class extends Controller {
  static targets = ["indicator"];
  static values = {
    threshold: { type: Number, default: 110 },
    max: { type: Number, default: 160 },
    deadzone: { type: Number, default: 20 },
  };

  connect() {
    if (!("ontouchstart" in window)) return;
    this.startY = null;
    this.lastDy = 0;
    this.pulling = false;
    this.refreshing = false;

    this.element.addEventListener("touchstart", this.onStart, { passive: true });
    this.element.addEventListener("touchmove", this.onMove, { passive: false });
    this.element.addEventListener("touchend", this.onEnd, { passive: true });
    this.element.addEventListener("touchcancel", this.onEnd, { passive: true });
  }

  disconnect() {
    this.element.removeEventListener("touchstart", this.onStart);
    this.element.removeEventListener("touchmove", this.onMove);
    this.element.removeEventListener("touchend", this.onEnd);
    this.element.removeEventListener("touchcancel", this.onEnd);
  }

  onStart = (e) => {
    if (this.refreshing) return;
    if (this.element.scrollTop > 0) {
      this.startY = null;
      this.startX = null;
      return;
    }
    this.startY = e.touches[0].clientY;
    this.startX = e.touches[0].clientX;
    this.lastDy = 0;
    this.pulling = false;
    this.aborted = false;
  };

  onMove = (e) => {
    if (this.refreshing || this.startY === null || this.aborted) return;
    if (this.element.scrollTop > 0) {
      this.#reset();
      return;
    }
    const dy = e.touches[0].clientY - this.startY;
    const dx = e.touches[0].clientX - this.startX;

    // Abort if the gesture is more horizontal than vertical
    if (Math.abs(dx) > Math.abs(dy)) {
      this.aborted = true;
      this.#reset();
      return;
    }

    if (dy <= this.deadzoneValue) return;

    this.pulling = true;
    e.preventDefault();
    const effective = Math.min(dy - this.deadzoneValue, this.maxValue);
    this.lastDy = effective;
    this.#updateIndicator(effective);
  };

  onEnd = () => {
    if (!this.pulling) return;
    if (this.lastDy >= this.thresholdValue) {
      this.#refresh();
    } else {
      this.#reset();
    }
  };

  #updateIndicator(dy) {
    if (!this.hasIndicatorTarget) return;
    const drop = Math.min(dy * 0.6, this.maxValue * 0.6);
    const opacity = Math.min(dy / this.thresholdValue, 1);
    const rotation = dy * 3;
    this.indicatorTarget.style.transform = `translate(-50%, ${drop}px) rotate(${rotation}deg)`;
    this.indicatorTarget.style.opacity = opacity;
  }

  #reset() {
    if (this.hasIndicatorTarget) {
      this.indicatorTarget.style.transition = "all 200ms";
      this.indicatorTarget.style.transform = "translate(-50%, 0)";
      this.indicatorTarget.style.opacity = "0";
      setTimeout(() => {
        if (this.hasIndicatorTarget) this.indicatorTarget.style.transition = "";
      }, 250);
    }
    this.startY = null;
    this.lastDy = 0;
    this.pulling = false;
  }

  #refresh() {
    this.refreshing = true;
    if (this.hasIndicatorTarget) {
      this.indicatorTarget.style.transition = "all 200ms";
      this.indicatorTarget.style.transform = `translate(-50%, ${this.thresholdValue}px) rotate(0deg)`;
      this.indicatorTarget.style.opacity = "1";
      this.indicatorTarget.classList.add("animate-spin");
    }
    const url = window.location.href;
    if (window.Turbo) {
      window.Turbo.visit(url, { action: "replace" });
    } else {
      window.location.reload();
    }
  }
}
