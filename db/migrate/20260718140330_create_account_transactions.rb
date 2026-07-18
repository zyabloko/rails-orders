class CreateAccountTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :account_transactions, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.references :order, null: false, foreign_key: true, type: :uuid
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :kind, null: false

      t.timestamps
    end
  end
end
