class BillPaymentsController < ApplicationController
  before_action :set_bill
  before_action :set_period

  def create
    @bill.mark_paid!(@period)
    redirect_back_or_to bills_path(period: @period.strftime("%Y-%m"))
  end

  def destroy
    @bill.unmark_paid!(@period)
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
