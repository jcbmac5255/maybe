domain = ENV.fetch("APP_DOMAIN", "lumen.nexgrid.cc")

WebAuthn.configure do |config|
  # The WebAuthn-spec "origin" is the page origin browsers see — must include scheme.
  config.allowed_origins = [ "https://#{domain}" ]

  # The "Relying Party" — what shows up in the browser's biometric prompt.
  config.rp_name = "Lumen"
  config.rp_id = domain

  # ES256 (most common) and RS256 (Windows Hello)
  config.algorithms = %w[ES256 RS256]
end
