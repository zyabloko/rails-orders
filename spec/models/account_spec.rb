require 'rails_helper'

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
RSpec.describe Account, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:account)).to be_valid
    end

    it 'allows a zero balance' do
      expect(build(:account, balance: 0)).to be_valid
    end

    it 'requires balance to be greater than or equal to 0' do
      account = build(:account, balance: -1)

      expect(account).not_to be_valid
      expect(account.errors[:balance]).to be_present
    end
  end

  describe 'associations' do
    it 'belongs to a user' do
      account = build(:account)

      expect(account.user).to be_present
    end

    it 'has many account_transactions' do
      account = create(:account)
      transaction = create(:account_transaction, account: account)

      expect(account.account_transactions).to include(transaction)
    end
  end
end
