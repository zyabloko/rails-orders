class AddAccountToOrders < ActiveRecord::Migration[7.2]
  def change
    add_reference :orders, :account, null: false, foreign_key: true, type: :uuid
  end
end
