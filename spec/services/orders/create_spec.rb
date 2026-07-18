require 'rails_helper'

RSpec.describe Orders::Create do
  describe '.call' do
    it 'creates an order for the given account' do
      user = create(:user)
      account = create(:account, user: user)

      order = described_class.call(user: user, amount: '10.00', account_id: account.id)

      expect(order).to be_persisted
      expect(order.user).to eq(user)
      expect(order.account).to eq(account)
      expect(order.amount).to eq(BigDecimal('10.00'))
    end

    it "defaults to the user's first account when account_id is omitted" do
      user = create(:user)

      order = described_class.call(user: user, amount: '10.00')

      expect(order.account).to eq(user.accounts.first)
    end

    it "raises when the account does not belong to the user" do
      user = create(:user)
      other_users_account = create(:account)

      expect do
        described_class.call(user: user, amount: '10.00', account_id: other_users_account.id)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises when the amount is invalid' do
      user = create(:user)

      expect do
        described_class.call(user: user, amount: '-1', account_id: user.accounts.first.id)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
