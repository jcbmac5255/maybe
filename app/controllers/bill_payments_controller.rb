class BillPaymentsController < ApplicationController
  before_action :set_bill
  before_action :set_period

  def create
    @bill.bill_payments.find_or_create_by!(period: @period) do |bp|
      bp.paid_at = Time.current
    end
    redirect_back_or_to bills_path(period: @period.strftime("%Y-%m"))
  end

  def destroy
    payment = @bill.bill_payments.find_by(period: @period)
    payment&.destroy
    redirect_back_or_to bills_path(period: @period.strftime("%Y-%m"))
  end

  private
    def set_bill
      @bill = Current.family.bills.find(params[:bill_id])
    end

    def set_period
      raw = params[:period].presence || Date.current.strftime("%Y-%m")
      @period = Date.strptime(raw, "%Y-%m").beginning_of_month
    rescue ArgumentError
      @period = Date.current.beginning_of_month
    end
end
