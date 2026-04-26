import { Controller } from "@hotwired/stimulus";

// Pairs with a password input + a "Clear" button. Click clear → wipes the
// input and submits the form so the cleared value persists.
export default class extends Controller {
  static targets = ["input"];

  clear() {
    this.inputTarget.value = "";
    this.inputTarget.closest("form")?.requestSubmit();
  }
}
