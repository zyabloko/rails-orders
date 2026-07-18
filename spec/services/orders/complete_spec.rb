require 'rails_helper'

RSpec.describe Orders::Complete do
  describe '.call' do
    it 'transitions the order to completed' do
      order = create(:order, amount: 20)
      order.account.update!(balance: 100)

      described_class.call(order)

      expect(order.reload.status).to eq('completed')
    end

    it 'debits the account balance by the order amount' do
      order = create(:order, amount: 20)
      order.account.update!(balance: 100)

      described_class.call(order)

      expect(order.account.reload.balance).to eq(80)
    end

    it 'creates a debit account_transaction for the order amount' do
      order = create(:order, amount: 20)
      order.account.update!(balance: 100)

      transaction = described_class.call(order)

      expect(transaction).to be_a(AccountTransaction)
      expect(transaction.kind).to eq('debit')
      expect(transaction.amount).to eq(order.amount)
      expect(transaction.order).to eq(order)
      expect(transaction.account).to eq(order.account)
    end

    it 'raises AlreadyProcessedError when the order is not in the created state' do
      order = create(:order, amount: 20)
      order.account.update!(balance: 100)
      order.complete!

      expect { described_class.call(order) }.to raise_error(Orders::AlreadyProcessedError)
    end

    it 'raises NotEnoughBalance when the account balance is insufficient' do
      order = create(:order, amount: 50)
      order.account.update!(balance: 10)

      expect { described_class.call(order) }.to raise_error(Orders::NotEnoughBalance)
    end
  end
end
