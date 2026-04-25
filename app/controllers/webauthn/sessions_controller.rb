class Webauthn::SessionsController < ApplicationController
  skip_authentication

  # Returns assertion challenge JSON
  def options
    options = WebAuthn::Credential.options_for_get(
      allow: WebauthnCredential.pluck(:external_id),
      user_verification: "preferred"
    )
    session[:webauthn_authentication_challenge] = options.challenge
    render json: options
  end

  # Verifies the assertion from the browser and signs in the matching user
  def create
    challenge = session.delete(:webauthn_authentication_challenge)
    return render(json: { error: "Missing challenge" }, status: :bad_request) unless challenge

    webauthn_credential = WebAuthn::Credential.from_get(params[:credential])
    record = WebauthnCredential.find_by(external_id: webauthn_credential.id)
    return render(json: { error: "Unknown credential" }, status: :unauthorized) unless record

    webauthn_credential.verify(
      challenge,
      public_key: record.public_key,
      sign_count: record.sign_count
    )

    record.update!(sign_count: webauthn_credential.sign_count, last_used_at: Time.current)

    user = record.user
    if user.otp_required?
      session[:mfa_user_id] = user.id
      render json: { redirect: verify_mfa_path }
    else
      create_session_for(user)
      render json: { redirect: root_path }
    end
  rescue WebAuthn::Error => e
    render json: { error: e.message }, status: :unauthorized
  end
end
