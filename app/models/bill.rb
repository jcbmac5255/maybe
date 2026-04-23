class Bill < ApplicationRecord
  include Monetizable

  belongs_to :family
  belongs_to :category, optional: true
  belongs_to :paid_from_account, class_name: "Account", optional: true
  has_many :bill_payments, dependent: :destroy

  monetize :amount

  validates :name, :amount, :currency, :due_day, presence: true
  validates :due_day, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 31 }

  scope :active, -> { where(active: true) }
  scope :alphabetically, -> { order(Arel.sql("LOWER(name)")) }

  def due_date_for(period)
    period_start = period.beginning_of_month
    last_day = period_start.end_of_month.day
    Date.new(period_start.year, period_start.month, [ due_day, last_day ].min)
  end

  def payment_for(period)
    bill_payments.find_by(period: period.beginning_of_month)
  end

  def paid?(period)
    payment_for(period).present?
  end

  def status_for(period, today: Date.current)
    return :paid if paid?(period)
    due_date_for(period) < today ? :overdue : :upcoming
  end

  def mark_paid!(period, at: Time.current)
    period_start = period.beginning_of_month
    existing = bill_payments.find_by(period: period_start)
    return existing if existing

    transaction do
      payment = bill_payments.build(period: period_start, paid_at: at)

      if paid_from_account
        payment.entry = paid_from_account.entries.create!(
          entryable: Transaction.new(category: category),
          name: name,
          amount: amount,
          currency: paid_from_account.currency,
          date: at.to_date,
          notes: "Bill payment"
        )
      end

      payment.save!
      payment.entry&.sync_account_later
      payment
    end
  end

  def unmark_paid!(period)
    payment = payment_for(period)
    return unless payment

    transaction do
      entry = payment.entry
      payment.destroy!

      if entry
        account = entry.account
        entry.destroy!
        account.sync_later
      end
    end
  end
end
