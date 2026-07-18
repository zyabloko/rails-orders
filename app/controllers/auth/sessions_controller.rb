module Auth
  class SessionsController < ApplicationController
    skip_before_action :authenticate_user!, only: :create

    def create
      user = User.find_by(email: params[:email])

      unless user&.valid_password?(params[:password])
        return render json: { error: "Invalid email or password" }, status: :unauthorized
      end

      session = user.sessions.create!
      render json: { token: session.token, expires_at: session.expires_at }, status: :created
    end

    def destroy
      current_session.destroy
      head :no_content
    end
  end
end
