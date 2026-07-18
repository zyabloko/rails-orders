require 'rails_helper'

RSpec.describe 'Orders', type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }

  describe 'POST /orders' do
    it 'returns unauthorized without a valid token' do
      post '/orders', params: { amount: '10.00' }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'delegates to Orders::Create and returns the created order' do
      account = user.accounts.first
      order = build_stubbed(:order, user: user, account: account)
      expect(Orders::Create).to receive(:call).with(
        user: user, amount: '10.00', account_id: account.id
      ).and_return(order)

      post '/orders', params: { amount: '10.00', account_id: account.id }, headers: headers

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['id']).to eq(order.id)
    end

    it 'returns unprocessable_entity when the order is invalid' do
      invalid_order = build(:order, user: user, amount: -1)
      invalid_order.validate
      allow(Orders::Create).to receive(:call).and_raise(ActiveRecord::RecordInvalid.new(invalid_order))

      post '/orders', params: { amount: '-1' }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to be_present
    end
  end

  describe 'POST /orders/:id/complete' do
    it 'returns unauthorized without a valid token' do
      order = create(:order)

      post "/orders/#{order.id}/complete"

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns not_found for another user's order" do
      other_order = create(:order)

      post "/orders/#{other_order.id}/complete", headers: headers

      expect(response).to have_http_status(:not_found)
    end

    it 'completes the order and returns it' do
      order = create(:order, user: user, amount: 5)
      order.account.update!(balance: 100)

      post "/orders/#{order.id}/complete", headers: headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['status']).to eq('completed')
    end

    it 'returns unprocessable_entity when the order is already processed' do
      order = create(:order, user: user, amount: 5)
      order.account.update!(balance: 100)
      order.complete!

      post "/orders/#{order.id}/complete", headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to eq('Order already processed')
    end

    it 'returns unprocessable_entity when the account balance is insufficient' do
      order = create(:order, user: user, amount: 50)
      order.account.update!(balance: 10)

      post "/orders/#{order.id}/complete", headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to eq('Not enough balance')
    end
  end

  describe 'POST /orders/:id/cancel' do
    it "returns not_found for another user's order" do
      other_order = create(:order)

      post "/orders/#{other_order.id}/cancel", headers: headers

      expect(response).to have_http_status(:not_found)
    end

    it 'cancels a completed order and returns it' do
      order = create(:order, user: user, amount: 5)
      order.account.update!(balance: 100)
      order.complete!

      post "/orders/#{order.id}/cancel", headers: headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['status']).to eq('canceled')
    end

    it 'returns unprocessable_entity when the order has not been completed' do
      order = create(:order, user: user)

      post "/orders/#{order.id}/cancel", headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to eq('Order already processed')
    end
  end
end
