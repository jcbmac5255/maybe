class InsightsController < ApplicationController
  def show
    @period = parse_period(params[:period])
    statement = Current.family.income_statement

    @income = statement.income_totals(period: @period)
    @expenses = statement.expense_totals(period: @period)

    # Filter to only top-level categories with non-zero totals, sorted desc
    @income_rows = top_level_rows(@income.category_totals)
    @expense_rows = top_level_rows(@expenses.category_totals)

    @currency = Current.family.currency

    @top_merchants = top_merchants(@period)

    @breadcrumbs = [ [ "Home", root_path ], [ "Insights", nil ] ]
  end

  private
    def parse_period(key)
      return Period.last_30_days if key.blank?
      Period.from_key(key)
    rescue Period::InvalidKeyError
      Period.last_30_days
    end

    def top_level_rows(category_totals)
      category_totals
        .reject { |ct| ct.category.subcategory? }
        .reject { |ct| ct.total.zero? }
        .sort_by { |ct| -ct.total.to_f }
    end

    def top_merchants(period, limit: 10)
      Current.family.transactions
        .visible
        .joins(:entry)
        .where(entries: { date: period.start_date..period.end_date })
        .where("entries.amount > 0") # expenses (positive amounts on the entry)
        .where.not(merchant_id: nil)
        .group(:merchant_id)
        .select("merchant_id, SUM(entries.amount) AS total, COUNT(*) AS txn_count")
        .order("total DESC")
        .limit(limit)
        .map do |row|
          merchant = Merchant.find_by(id: row.merchant_id)
          next nil unless merchant
          { merchant: merchant, total: row.total, count: row.txn_count }
        end
        .compact
    end
end
