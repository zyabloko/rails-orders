module Orders
  class Create
    include Callable

    def initialize(user:, amount:, account_id: nil)
      @user = user
      @amount = amount
      @account_id = account_id
    end

    def call
      account = @account_id ? @user.accounts.find(@account_id) : @user.accounts.first
      Order.create!(user: @user, amount: @amount, account: account)
    end
  end
end
