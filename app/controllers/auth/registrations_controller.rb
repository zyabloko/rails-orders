module Auth
  class RegistrationsController < ApplicationController
    skip_before_action :authenticate_user!

    def create
      user = User.new(registration_params)

      if user.save
        session = user.sessions.create!
        render json: { token: session.token, expires_at: session.expires_at }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def registration_params
      params.permit(:email, :password, :password_confirmation)
    end
  end
end
