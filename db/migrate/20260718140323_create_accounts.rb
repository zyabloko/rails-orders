class CreateAccounts < ActiveRecord::Migration[7.2]
  def change
    create_table :accounts, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.decimal :balance, precision: 10, scale: 2, null: false, default: "0.0"

      t.timestamps
    end
  end
end
