require 'rails_helper'

RSpec.describe 'PasswordResets', type: :request do
  let(:daniel) { create(:user) }

  describe 'POST /api/password_resets' do
    before do
      allow_any_instance_of(PasswordResetsController).to(
          receive(:validate_auth_scheme).and_return(true))
      allow_any_instance_of(PasswordResetsController).to(
          receive(:authenticate_client).and_return(true))
    end

    context 'with valid params' do
      let(:params) do
        {
            data: {
                email: daniel.email,
                reset_password_redirect_url: 'http://sandra.app'
            }
        }
      end

      before { post '/api/password_resets', params: params }

      it 'return 204' do
        expect(response.status).to be 204
      end

      it 'sends the reset password email' do
        expect(ActionMailer::Base.deliveries.last.subject).to eq 'Reset your password'
      end

      it 'adds the reset password token to "daniel"' do
        expect(daniel.reset_password_token).to be_nil
        expect(daniel.reset_password_sent_at).to be_nil
        updated = daniel.reload
        expect(updated.reset_password_token).to_not be_nil
        expect(updated.reset_password_sent_at).to_not be_nil
        expect(updated.reset_password_redirect_url).to eq 'http://sandra.app'
      end
    end

    context 'with invalid params' do
      let(:params) { { data: { email: daniel.email } } }

      before { post '/api/password_resets', params: params }

      it 'returns HTTP status 422' do
        expect(response.status).to eq 422
      end
    end

    context 'with nonexistent user' do
      let(:params) { { data: { email: 'invalid@sandra.app' } } }

      before { post '/api/password_resets', params: params }

      it 'returns HTTP status 404' do
        expect(response.status).to eq 404
      end
    end
  end

  describe 'GET /api/password_resets/:reset_token' do
    context 'with existing user (valid token)' do
      subject { get "/api/password_resets/#{daniel.reset_password_token}" }

      context 'with existing URL containing parameters' do
        let(:daniel) { create(:user, :reset_password)}

        it 'redirects to "http://sandra.app?some=params&reset_token=TOKEN"' do
          token = daniel.reset_password_token
          expect(subject).to redirect_to(
             "http://sandra.app?some=params&reset_token=#{token}")
        end
      end

      context 'with existing URL not containing parameters' do
        let(:daniel) { create(:user, :reset_password_no_params)}

        it 'redirects to "http://sandra.app?reset_token=TOKEN"' do
          token = daniel.reset_password_token
          expect(subject).to redirect_to(
                                 "http://sandra.app?reset_token=#{token}")
        end
      end
    end

    context 'with nonexistent user' do
      before { get '/api/password_resets/fake_reset_token' }

      it 'returns HTTP status 404' do
        expect(response.status).to eq 404
      end
    end
  end
end