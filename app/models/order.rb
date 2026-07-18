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
class Order < ApplicationRecord
  include AASM

  belongs_to :user
  belongs_to :account
  has_one :account_transaction

  validates :amount, numericality: { greater_than: 0 }
  validate :account_belongs_to_user

  aasm column: :status, whiny_transitions: true, no_direct_assignment: true do
    state :created, initial: true
    state :completed
    state :canceled

    event :complete do
      transitions from: :created, to: :completed
    end

    event :cancel do
      transitions from: :completed, to: :canceled
    end
  end

  private

  def account_belongs_to_user
    errors.add(:account, "must belong to the order's user") if account && account.user_id != user_id
  end
end
