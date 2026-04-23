class AddPaidFromAccountToBills < ActiveRecord::Migration[7.2]
  def change
    add_reference :bills, :paid_from_account, type: :uuid, foreign_key: { to_table: :accounts }, null: true
    add_reference :bill_payments, :entry, type: :uuid, foreign_key: true, null: true
  end
end
