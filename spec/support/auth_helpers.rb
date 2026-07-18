module AuthHelpers
  def auth_headers(user)
    session = user.sessions.create!
    { 'Authorization' => "Bearer #{session.token}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
