require 'rails_helper'

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
RSpec.describe Order, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = create(:user)

      expect(build(:order, user: user, account: user.accounts.first)).to be_valid
    end

    it 'requires amount to be greater than 0' do
      order = build(:order, amount: 0)

      expect(order).not_to be_valid
      expect(order.errors[:amount]).to be_present
    end

    it 'requires the account to belong to the order user' do
      other_user = create(:user)
      order = build(:order, account: other_user.accounts.first)

      expect(order).not_to be_valid
      expect(order.errors[:account]).to include("must belong to the order's user")
    end
  end

  describe 'state machine' do
    it 'starts in the created state' do
      expect(create(:order).status).to eq('created')
    end

    it 'transitions from created to completed' do
      order = create(:order)

      order.complete!

      expect(order.status).to eq('completed')
    end

    it 'transitions from completed to canceled' do
      order = create(:order)
      order.complete!

      order.cancel!

      expect(order.status).to eq('canceled')
    end

    it 'does not allow completing an already completed order' do
      order = create(:order)
      order.complete!

      expect { order.complete! }.to raise_error(AASM::InvalidTransition)
    end

    it 'does not allow canceling an order that has not been completed' do
      order = create(:order)

      expect { order.cancel! }.to raise_error(AASM::InvalidTransition)
    end

    it 'does not allow assigning status directly' do
      order = create(:order)

      expect { order.status = 'completed' }.to raise_error(AASM::NoDirectAssignmentError)
    end
  end
end
