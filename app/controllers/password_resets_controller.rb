class PasswordResetsController < ApplicationController
  skip_before_action :validate_auth_scheme, only: :show
  skip_before_action :authenticate_client, only: :show

  def show
    redirect_to reset.redirect_url
  end

  def create
    if reset.create
      UserMailer.reset_password(reset.user).deliver_now
      render status: :no_content, location: reset.user
    else
      unprocessable_entity!(reset)
    end
  end

  def update
  end

  private

  def reset
    @reset ||= if params[:reset_token]
                 PasswordReset.new(reset_password_token: params[:reset_token])
               else
                 PasswordReset.new(reset_params)
               end
  end

  def reset_params
    params.require(:data).permit(:email, :reset_password_redirect_url)
  end
end