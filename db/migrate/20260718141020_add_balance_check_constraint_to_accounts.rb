class AddBalanceCheckConstraintToAccounts < ActiveRecord::Migration[7.2]
  def change
    add_check_constraint :accounts, "balance >= 0", name: "chk_accounts_balance_non_negative"
  end
end
