class OrdersController < ApplicationController
  before_action :set_order, only: %i[complete cancel]

  def create
    order = Orders::Create.call(
      user: current_user,
      amount: create_orders_params[:amount],
      account_id: create_orders_params[:account_id]
    )
    render json: order, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def complete
    Orders::Complete.call(@order)
    render json: @order.reload
  rescue Orders::AlreadyProcessedError
    render json: { error: "Order already processed" }, status: :unprocessable_entity
  rescue Orders::NotEnoughBalance
    render json: { error: "Not enough balance" }, status: :unprocessable_entity
  end

  def cancel
    Orders::Cancel.call(@order)
    render json: @order.reload
  rescue Orders::AlreadyProcessedError
    render json: { error: "Order already processed" }, status: :unprocessable_entity
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  end

  def create_orders_params
    params.permit(:amount, :account_id)
  end
end
