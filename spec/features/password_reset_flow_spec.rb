require 'rails_helper'

RSpec.describe 'Password Reset Flow', type: :request do
  let(:daniel) { create(:user) }

  let(:api_key) { ApiKey.create }

  let(:headers) { { 'HTTP_AUTHORIZATION' => "Sandra-Token api_key=#{api_key.id}:#{api_key.key}" } }

  let(:create_params) { { data: { email: daniel.email, reset_password_redirect_url: 'http://example.com' } } }

  let(:update_params) { { data: { password: 'new_password' } } }

  it 'resets the password' do
    expect(daniel.authenticate('password')).to_not be_falsey
    expect(daniel.reset_password_token).to be_nil

    # Step 1
    post '/api/password_resets', params: create_params, headers: headers
    expect(response.status).to eq 204
    reset_token = daniel.reload.reset_password_token
    expect(ActionMailer::Base.deliveries.last.to).to eq [daniel.email]

    # Step 2
    sbj = get "/api/password_resets/#{reset_token}"
    expect(sbj).to redirect_to("http://example.com?reset_token=#{reset_token}")

    # Step 3
    patch "/api/password_resets/#{reset_token}",
          params: update_params, headers: headers
    expect(response.status).to eq 204
    expect(daniel.reload.authenticate('new_password')).to_not be_falsey
  end
end