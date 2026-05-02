class BillPayment < ApplicationRecord
  belongs_to :bill
  belongs_to :entry, optional: true

  validates :period, :paid_at, presence: true
  validates :period, uniqueness: { scope: :bill_id }

  before_validation :normalize_period
  after_destroy :remove_linked_entry

  private
    def normalize_period
      self.period = period.beginning_of_month if period.present?
    end

    def remove_linked_entry
      return unless entry

      account = entry.account
      entry.destroy!
      account&.sync_later
    end
end
