import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["error"];

  async login(event) {
    event.preventDefault();
    if (!window.PublicKeyCredential) {
      this.#fail("This browser doesn't support passkeys.");
      return;
    }

    try {
      const optsRes = await fetch("/webauthn/session/options", {
        headers: { Accept: "application/json" },
      });
      if (!optsRes.ok) throw new Error("Could not get sign-in challenge");
      const opts = await optsRes.json();

      const assertion = await navigator.credentials.get({
        publicKey: this.#decodeOptions(opts),
      });

      const token = document.querySelector('meta[name="csrf-token"]')?.content;
      const verifyRes = await fetch("/webauthn/session", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          "X-CSRF-Token": token || "",
        },
        body: JSON.stringify({ credential: this.#encodeAssertion(assertion) }),
      });

      const body = await verifyRes.json().catch(() => ({}));
      if (verifyRes.ok && body.redirect) {
        window.location.href = body.redirect;
      } else {
        this.#fail(body.error || "Sign-in failed");
      }
    } catch (e) {
      if (e.name === "NotAllowedError" || e.name === "AbortError") return;
      console.error("Passkey login error:", e);
      this.#fail(`${e.name || "Error"}: ${e.message || "Passkey sign-in failed"}`);
    }
  }

  #fail(msg) {
    if (this.hasErrorTarget) this.errorTarget.textContent = msg;
  }

  #decodeOptions(opts) {
    return {
      ...opts,
      challenge: b64urlToBuffer(opts.challenge),
      allowCredentials: (opts.allowCredentials || []).map((c) => ({
        ...c,
        id: b64urlToBuffer(c.id),
      })),
    };
  }

  #encodeAssertion(cred) {
    return {
      id: cred.id,
      rawId: bufferToB64url(cred.rawId),
      type: cred.type,
      response: {
        clientDataJSON: bufferToB64url(cred.response.clientDataJSON),
        authenticatorData: bufferToB64url(cred.response.authenticatorData),
        signature: bufferToB64url(cred.response.signature),
        userHandle: cred.response.userHandle ? bufferToB64url(cred.response.userHandle) : null,
      },
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
