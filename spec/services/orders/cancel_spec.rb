require 'rails_helper'

RSpec.describe Orders::Cancel do
  describe '.call' do
    def complete_order(amount: 20, balance: 100)
      order = create(:order, amount: amount)
      order.account.update!(balance: balance)
      order.complete!
      order
    end

    it 'transitions the order to canceled' do
      order = complete_order

      described_class.call(order)

      expect(order.reload.status).to eq('canceled')
    end

    it 'credits the account balance by the order amount' do
      order = complete_order(amount: 20, balance: 100)
      balance_after_complete = order.account.reload.balance

      described_class.call(order)

      expect(order.account.reload.balance).to eq(balance_after_complete + order.amount)
    end

    it 'creates a storno account_transaction for the order amount' do
      order = complete_order(amount: 20)

      expect { described_class.call(order) }
        .to change { AccountTransaction.where(order: order, kind: 'storno').count }.by(1)

      transaction = AccountTransaction.where(order: order, kind: 'storno').last
      expect(transaction.amount).to eq(order.amount)
      expect(transaction.account).to eq(order.account)
    end

    it 'raises AlreadyProcessedError when the order has not been completed' do
      order = create(:order, amount: 20)

      expect { described_class.call(order) }.to raise_error(Orders::AlreadyProcessedError)
    end

    it 'raises AlreadyProcessedError when the order is already canceled' do
      order = complete_order
      described_class.call(order)

      expect { described_class.call(order) }.to raise_error(Orders::AlreadyProcessedError)
    end
  end
end
