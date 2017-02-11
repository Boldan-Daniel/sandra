module Authentication
  include ActiveSupport::SecurityUtils
  extend ActiveSupport::Concern

  AUTH_SCHEME = 'Sandra-Token'

  included do
    before_action :validate_auth_scheme
    before_action :authenticate_client
  end

  private

  def validate_auth_scheme
    unless authorization_request.match(/^#{AUTH_SCHEME}/)
      unauthorized!('Client Realm')
    end
  end

  def authenticate_client
    unauthorized!('Client Realm') unless api_key
  end

  def authenticate_user
    unauthorized!('User Realm') unless access_token
  end

  def unauthorized!(realm)
    headers['WWW-Authenticate'] = %(#{AUTH_SCHEME} realm="#{realm}")
    render(status: 401)
  end

  def authorization_request
    @authorization_request ||= request.authorization.to_s
  end

  def credentials
    @credentials ||= Hash[authorization_request.scan(/(\w+)[:=] ?"?([\w|:]+)"?/)]
  end

  def api_key
    @api_key ||= compute_api_key
  end

  def compute_api_key
    return nil if credentials['api_key'].blank?

    id, key = credentials['api_key'].split(':')
    valid_key = id && key && ApiKey.activated.find_by(id: id)

    return valid_key if valid_key && secure_compare_with_hashing(valid_key.key, key)
  end

  def access_token
    @access_token ||= compute_access_token
  end

  def compute_access_token
    return nil if credentials['access_token'].blank?

    id, token = credentials['access_token'].split(':')
    user = id && token && User.find_by(id: id)
    access_token = user && api_key && AccessToken.find_by(user: user, api_key: api_key)

    return nil unless access_token

    if access_token.expired?
      access_token.destroy
      return nil
    end

    access_token if access_token.authenticate(token)
  end

  def current_user
    @current_user ||= access_token.try(:user)
  end

  def secure_compare_with_hashing(a, b)
    secure_compare(Digest::SHA1.hexdigest(a), Digest::SHA1.hexdigest(b))
  end
end