require 'rails_helper'

RSpec.describe 'Auth::Registrations', type: :request do
  describe 'POST /auth/sign_up' do
    it 'creates a user and returns a session token' do
      post '/auth/sign_up', params: {
        email: 'new@example.com', password: 'password123', password_confirmation: 'password123'
      }

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body['token']).to be_present
      expect(body['expires_at']).to be_present
      expect(User.find_by(email: 'new@example.com')).to be_present
    end

    it 'does not require authentication' do
      post '/auth/sign_up', params: {
        email: 'noauth@example.com', password: 'password123', password_confirmation: 'password123'
      }

      expect(response).not_to have_http_status(:unauthorized)
    end

    it 'returns unprocessable_entity for an invalid email' do
      post '/auth/sign_up', params: { email: '', password: 'password123', password_confirmation: 'password123' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to be_present
    end

    it 'returns unprocessable_entity when the password confirmation does not match' do
      post '/auth/sign_up', params: {
        email: 'mismatch@example.com', password: 'password123', password_confirmation: 'nope'
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns unprocessable_entity for a duplicate email' do
      create(:user, email: 'dup@example.com')

      post '/auth/sign_up', params: {
        email: 'dup@example.com', password: 'password123', password_confirmation: 'password123'
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
