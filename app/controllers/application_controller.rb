class ApplicationController < ActionController::API
  before_action :authenticate_user!

  private

  def authenticate_user!
    token = bearer_token
    return unauthorized! unless token

    @current_session = Session.active.find_by(token: token)
    return unauthorized! unless @current_session

    @current_user = @current_session.user
  end

  def current_user
    @current_user
  end

  def current_session
    @current_session
  end

  def bearer_token
    header = request.headers["Authorization"]
    header&.split(" ")&.last if header&.start_with?("Bearer ")
  end

  def unauthorized!
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
