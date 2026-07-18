# == Schema Information
#
# Table name: accounts
#
#  id         :uuid             not null, primary key
#  balance    :decimal(10, 2)   default(0.0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid             not null
#
# Indexes
#
#  index_accounts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Account < ApplicationRecord
  belongs_to :user
  has_many :account_transactions

  validates :balance, numericality: { greater_than_or_equal_to: 0 }
end
