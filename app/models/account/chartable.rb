module Account::Chartable
  extend ActiveSupport::Concern

  def favorable_direction
    classification == "asset" ? "up" : "down"
  end

  def balance_series(period: Period.last_30_days, view: :balance, interval: nil)
    raise ArgumentError, "Invalid view type" unless [ :balance, :cash_balance, :holdings_balance ].include?(view.to_sym)

    @balance_series ||= {}

    memo_key = [ period.start_date, period.end_date, interval ].compact.join("_")

    builder = (@balance_series[memo_key] ||= Balance::ChartSeriesBuilder.new(
      account_ids: [ id ],
      currency: self.currency,
      period: period,
      favorable_direction: favorable_direction,
      interval: interval
    ))

    builder.send("#{view}_series")
  end

  def sparkline_series
    Rails.cache.fetch(sparkline_cache_key, expires_in: 24.hours) do
      balance_series
    end
  end

  # Per-account cache key. Family-wide invalidation made every account sparkline
  # bust on every sync, which stampedes the request pool on the accounts list.
  # Now this key only changes when this account's own data does.
  def sparkline_cache_key
    [
      family_id,
      id,
      "sparkline",
      updated_at.to_i,
      balances.maximum(:updated_at)&.to_i
    ].compact.join("_")
  end
end
