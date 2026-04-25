class Webauthn::CredentialsController < ApplicationController
  # Returns the challenge JSON the browser passes to navigator.credentials.create()
  def options
    Current.user.ensure_webauthn_id!

    options = WebAuthn::Credential.options_for_create(
      user: { id: Current.user.webauthn_id, name: Current.user.email, display_name: Current.user.display_name },
      exclude: Current.user.webauthn_credentials.pluck(:external_id),
      authenticator_selection: { residentKey: "preferred", userVerification: "preferred" }
    )

    session[:webauthn_registration_challenge] = options.challenge
    render json: options
  end

  # Verifies the attestation the browser produced and stores the credential.
  def create
    challenge = session.delete(:webauthn_registration_challenge)
    return render(json: { error: "Missing challenge" }, status: :bad_request) unless challenge

    webauthn_credential = WebAuthn::Credential.from_create(params[:credential])
    webauthn_credential.verify(challenge)

    Current.user.webauthn_credentials.create!(
      external_id: webauthn_credential.id,
      public_key: webauthn_credential.public_key,
      sign_count: webauthn_credential.sign_count,
      nickname: params[:nickname].presence || default_nickname
    )

    render json: { ok: true }
  rescue WebAuthn::Error, ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def destroy
    cred = Current.user.webauthn_credentials.find(params[:id])
    cred.destroy
    redirect_to settings_security_path, notice: "Passkey removed"
  end

  private
    def default_nickname
      ua = request.user_agent.to_s
      if ua.include?("iPhone")
        "iPhone"
      elsif ua.include?("iPad")
        "iPad"
      elsif ua.include?("Mac OS X")
        "Mac"
      elsif ua.include?("Android")
        "Android"
      elsif ua.include?("Windows")
        "Windows"
      else
        "Passkey"
      end
    end
end
