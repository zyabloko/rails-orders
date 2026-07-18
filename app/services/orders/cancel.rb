module Orders
  class Cancel
    include Callable

    def initialize(order)
      @order = order
    end

    def call
      ActiveRecord::Base.transaction do
        order = @order.lock!
        account = order.account.lock!

        raise AlreadyProcessedError unless order.may_cancel?

        AccountTransaction.create!(
          account: account,
          order: order,
          amount: order.amount,
          kind: :storno
        )

        account.increment!(:balance, order.amount)

        order.cancel!
      end
    end
  end
end
