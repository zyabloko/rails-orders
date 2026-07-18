# == Schema Information
#
# Table name: orders
#
#  id         :uuid             not null, primary key
#  amount     :decimal(10, 2)   not null
#  status     :string           default("created"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :uuid             not null
#  user_id    :uuid             not null
#
# Indexes
#
#  index_orders_on_account_id  (account_id)
#  index_orders_on_status      (status)
#  index_orders_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :order do
    user
    account { user.accounts.first }
    amount { "9.99" }
  end
end
