class CreateBills < ActiveRecord::Migration[7.2]
  def change
    create_table :bills, id: :uuid do |t|
      t.references :family, null: false, foreign_key: true, type: :uuid
      t.references :category, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.decimal :amount, precision: 19, scale: 4, null: false
      t.string :currency, null: false
      t.integer :due_day, null: false
      t.text :notes
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    create_table :bill_payments, id: :uuid do |t|
      t.references :bill, null: false, foreign_key: true, type: :uuid
      t.date :period, null: false
      t.datetime :paid_at, null: false

      t.timestamps
    end

    add_index :bill_payments, [ :bill_id, :period ], unique: true
  end
end
