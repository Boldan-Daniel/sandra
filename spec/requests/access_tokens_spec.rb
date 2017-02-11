require 'rails_helper'

RSpec.describe 'Access Tokens', type: :request do
  let(:daniel) { create(:user) }

  describe 'POST /api/access_tokens' do
    context 'with valid API key' do
      let(:key) { ApiKey.create }
      let(:headers) { { 'HTTP_AUTHORIZATION' => "Sandra-Token api_key:#{key.id}:#{key.key}" } }

      before { post '/api/access_tokens', params: params, headers: headers }

      context 'with existing user' do
        context 'with valid password' do
          let(:params) { { data: { email: daniel.email, password: daniel.password } } }

          it 'gets HTTP status 201' do
            expect(response.status).to eq 201
          end

          it 'receives an access token' do
            expect(json_body['data']['token']).to_not be_nil
          end

          it 'receives the user embedded' do
            expect(json_body['data']['user']['id']).to eq daniel.id
          end
        end

        context 'with invalid password' do
          let(:params) { { data: { email: daniel.email, password: 'fake' } } }

          it 'gets HTTP status 422 Unprocessable Entity' do
            expect(response.status).to eq 422
          end
        end
      end

      context 'with nonexistent user' do
        let(:params) { { data: { email: 'unknown', password: 'fake' } } }

        it 'gets HTTPS status 404 Not Found' do
          expect(response.status).to eq 404
        end
      end
    end

    context 'with invalid API key' do
      it 'gets HTTP status 401 Forbidden' do
        post '/api/access_tokens', params: {}
        expect(response.status).to eq 401
      end
    end
  end

  describe 'DELETE /api/access_tokens' do
    context 'with valid API token' do
      let(:api_key) { ApiKey.create }
      let(:api_key_str) { "#{api_key.id}:#{api_key.key}" }

      before { delete '/api/access_tokens', headers: headers }

      context 'with valid access tokens' do
        let(:access_token) { create(:access_token, api_key: api_key, user: daniel) }
        let(:token) { access_token.generate_token }
        let(:token_str) { "#{daniel.id}:#{token}"}

        let(:headers) { { 'HTTP_AUTHORIZATION' => "Sandra-Token api_key=#{api_key_str} access_token=#{token_str}" } }

        it 'gets HTTP status 204 No Content' do
          expect(response.status).to eq 204
        end

        it 'destroy the access token' do
          expect(daniel.reload.access_tokens.size).to eq 0
        end
      end

      context 'with invalid access tokens' do
        let(:headers) { { 'HTTP_AUTHORIZATION' => "Sandra-Token api_key=#{api_key_str} access_token=1:fake" } }

        it 'gets HTTP status 401 Forbidden' do
          expect(response.status).to eq 401
        end
      end
    end

    context 'with invalid API token' do
      it 'gets HTTP status 401 Forbidden' do
        delete '/api/access_tokens', params: {}
        expect(response.status).to eq 401
      end
    end
  end
end