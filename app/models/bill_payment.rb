class BillPayment < ApplicationRecord
  belongs_to :bill

  validates :period, :paid_at, presence: true
  validates :period, uniqueness: { scope: :bill_id }

  before_validation :normalize_period

  private
    def normalize_period
      self.period = period.beginning_of_month if period.present?
    end
end
