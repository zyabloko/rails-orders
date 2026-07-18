require 'rails_helper'

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
RSpec.describe AccountTransaction, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:account_transaction)).to be_valid
    end

    it 'requires amount to be greater than 0' do
      transaction = build(:account_transaction, amount: 0)

      expect(transaction).not_to be_valid
      expect(transaction.errors[:amount]).to be_present
    end
  end

  describe 'kind' do
    it 'allows debit and storno' do
      expect(build(:account_transaction, kind: 'debit')).to be_valid
      expect(build(:account_transaction, kind: 'storno')).to be_valid
    end

    it 'raises for an invalid kind' do
      expect { build(:account_transaction, kind: 'invalid') }.to raise_error(ArgumentError)
    end
  end

  describe 'associations' do
    it 'belongs to an account and an order' do
      transaction = create(:account_transaction)

      expect(transaction.account).to be_present
      expect(transaction.order).to be_present
    end
  end
end
