module Orders
  class Complete
    include Callable

    def initialize(order)
      @order = order
    end

    def call
      ActiveRecord::Base.transaction do
        order = @order.lock!
        account = order.account.lock!

        raise AlreadyProcessedError unless order.may_complete?
        raise NotEnoughBalance if account.balance < order.amount

        account_transaction = AccountTransaction.create!(
          account: account,
          order: order,
          amount: order.amount,
          kind: :debit
        )

        account.decrement!(:balance, order.amount)

        order.complete!

        account_transaction
      end
    end
  end
end
