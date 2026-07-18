# == Schema Information
#
# Table name: account_transactions
#
#  id         :uuid             not null, primary key
#  amount     :decimal(10, 2)   not null
#  kind       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :uuid             not null
#  order_id   :uuid             not null
#
# Indexes
#
#  index_account_transactions_on_account_id  (account_id)
#  index_account_transactions_on_order_id    (order_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (order_id => orders.id)
#
FactoryBot.define do
  factory :account_transaction do
    account
    order
    amount { "9.99" }
    kind { "debit" }
  end
end
