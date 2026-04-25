import { Controller } from "@hotwired/stimulus";

// Registers a new passkey for the current user.
// Click handler -> fetch challenge -> navigator.credentials.create() ->
// POST the attestation back -> reload to show the new credential.
export default class extends Controller {
  static targets = ["error"];

  async register(event) {
    event.preventDefault();
    if (!window.PublicKeyCredential) {
      this.#fail("This browser doesn't support passkeys.");
      return;
    }

    try {
      const optsRes = await fetch("/webauthn/credentials/options", {
        headers: { Accept: "application/json" },
      });
      if (!optsRes.ok) throw new Error("Could not get registration challenge");
      const opts = await optsRes.json();

      const credential = await navigator.credentials.create({
        publicKey: this.#decodeOptions(opts),
      });

      const token = document.querySelector('meta[name="csrf-token"]')?.content;
      const verifyRes = await fetch("/webauthn/credentials", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          "X-CSRF-Token": token || "",
        },
        body: JSON.stringify({ credential: this.#encodeCredential(credential) }),
      });

      if (verifyRes.ok) {
        window.location.reload();
      } else {
        const body = await verifyRes.json().catch(() => ({}));
        this.#fail(body.error || "Could not register passkey");
      }
    } catch (e) {
      // User cancelling the OS prompt throws a NotAllowedError — show nothing
      if (e.name === "NotAllowedError" || e.name === "AbortError") return;
      console.error("Passkey registration error:", e);
      this.#fail(`${e.name || "Error"}: ${e.message || "Passkey registration failed"}`);
    }
  }

  #fail(msg) {
    if (this.hasErrorTarget) this.errorTarget.textContent = msg;
  }

  #decodeOptions(opts) {
    return {
      ...opts,
      challenge: b64urlToBuffer(opts.challenge),
      user: { ...opts.user, id: b64urlToBuffer(opts.user.id) },
      excludeCredentials: (opts.excludeCredentials || []).map((c) => ({
        ...c,
        id: b64urlToBuffer(c.id),
      })),
    };
  }

  #encodeCredential(cred) {
    return {
      id: cred.id,
      rawId: bufferToB64url(cred.rawId),
      type: cred.type,
      response: {
        clientDataJSON: bufferToB64url(cred.response.clientDataJSON),
        attestationObject: bufferToB64url(cred.response.attestationObject),
      },
      authenticatorAttachment: cred.authenticatorAttachment,
    };
  }
}

function b64urlToBuffer(s) {
  const padded = s.replace(/-/g, "+").replace(/_/g, "/").padEnd(s.length + (4 - (s.length % 4)) % 4, "=");
  const bin = atob(padded);
  const buf = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) buf[i] = bin.charCodeAt(i);
  return buf.buffer;
}

function bufferToB64url(buf) {
  const bytes = new Uint8Array(buf);
  let bin = "";
  for (let i = 0; i < bytes.length; i++) bin += String.fromCharCode(bytes[i]);
  return btoa(bin).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}
