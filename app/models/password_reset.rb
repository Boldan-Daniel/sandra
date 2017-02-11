class PasswordReset
  include ActiveModel::Model

  attr_accessor :email, :reset_password_redirect_url, :reset_password_token

  validates :email, presence: true
  validates :reset_password_redirect_url, presence: true

  def create
    user && valid? && user.init_password_reset(reset_password_redirect_url)
  end

  def redirect_url
    build_redirect_url
  end

  def user
    @user ||= retrieve_user
  end

  private

  def retrieve_user
    user = email ? user_with_email : user_with_reset_token
    raise ActiveRecord::RecordNotFound unless user
    user
  end

  def user_with_email
    User.where(email: email).first
  end

  def user_with_reset_token
    User.where(reset_password_token: reset_password_token).first
  end

  def build_redirect_url
    url = user.reset_password_redirect_url
    query_params = Rack::Utils.parse_query(URI(url).query)
    separator = query_params.any? ? '&' : '?'
    "#{url}#{separator}reset_token=#{reset_password_token}"
  end
end