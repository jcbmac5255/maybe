class WebauthnCredential < ApplicationRecord
  belongs_to :user

  validates :external_id, :public_key, :sign_count, presence: true

  scope :ordered, -> { order(created_at: :desc) }
end
