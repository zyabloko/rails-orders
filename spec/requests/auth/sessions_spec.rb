require 'rails_helper'

RSpec.describe 'Auth::Sessions', type: :request do
  describe 'POST /auth/sign_in' do
    let!(:user) { create(:user, password: 'password123') }

    it 'returns a session token for valid credentials' do
      post '/auth/sign_in', params: { email: user.email, password: 'password123' }

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body['token']).to be_present
      expect(body['expires_at']).to be_present
    end

    it 'does not require authentication' do
      post '/auth/sign_in', params: { email: user.email, password: 'password123' }

      expect(response).not_to have_http_status(:unauthorized)
    end

    it 'returns unauthorized for an invalid password' do
      post '/auth/sign_in', params: { email: user.email, password: 'wrong' }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns unauthorized for an unknown email' do
      post '/auth/sign_in', params: { email: 'nope@example.com', password: 'password123' }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /auth/sign_out' do
    it 'destroys the current session' do
      user = create(:user)
      session = user.sessions.create!

      delete '/auth/sign_out', headers: { 'Authorization' => "Bearer #{session.token}" }

      expect(response).to have_http_status(:no_content)
      expect(Session.exists?(session.id)).to be false
    end

    it 'returns unauthorized without a token' do
      delete '/auth/sign_out'

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
