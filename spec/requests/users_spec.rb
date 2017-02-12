require 'rails_helper'

RSpec.describe 'Users', type: :request do
  include_context 'Skip Auth'

  let(:daniel) { create :user }
  let(:john)   { create :user, email: 'john@sandra.app', given_name: 'John', family_name: 'Hopkins' }

  let(:users) { [daniel, john] }

  describe 'GET /api/users' do
    before { users }

    context 'default behavior' do
      before { get '/api/users' }

      it 'receives HTTP status 200' do
        expect(response.status).to eq 200
      end

      it 'receives a json with the "data" root key' do
        expect(json_body['data']).to_not be_nil
      end

      it 'receives all 2 users' do
        expect(json_body['data'].size).to eq 3
      end
    end

    describe 'field picking' do
      context 'with the fields parameter' do
        before { get '/api/users?fields=id,given_name,family_name'}

        it 'gets users with only the id, given_name and family_name keys' do
          json_body['data'].each do |user|
            expect(user.keys).to eq ['id', 'given_name', 'family_name']
          end
        end
      end

      context 'without the fields parameter' do
        before { get '/api/users' }

        it 'gets users with all the fields specified in the presenter' do
          json_body['data'].each do |user|
            expect(user.keys).to eq UserPresenter.build_attributes.map(&:to_s)
          end
        end
      end

      context 'with invalid fields parameter "fields=fid,given_name"' do
        before { get '/api/users?fields=fid,given_name'}

        it 'get "400 Bad Request" back' do
          expect(response.status).to eq 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be_nil
        end

        it 'receives "fields=fid" as an invalid param' do
          expect(json_body['error']['invalid_params']).to eq 'fields=fid'
        end
      end
    end

    describe 'pagination' do
      context 'when asking for the first page' do
        before { get '/api/users?page=1&per=1' }

        it 'receives HTTP status 200' do
          expect(response.status).to eq 200
        end

        it 'receives only 1 users' do
          expect(json_body['data'].size).to eq 1
        end

        it 'receives a response with the Link header' do
          expect(response.headers['Link'].split(', ').first).to eq (
                                                                       '<http://www.example.com/api/users?page=2&per=1>; rel="next"'
                                                                   )
        end
      end

      context 'when asking for the next page' do
        before { get '/api/users?page=2&per=1' }

        it 'receives HTTP status 200' do
          expect(response.status).to eq 200
        end

        it 'receives only one user' do
          expect(json_body['data'].size).to eq 1
        end
      end

      context 'when sending invalid "page" and "per" parameters' do
        before { get '/api/users?page=fake&per=10' }

        it 'receives HTTP status 400' do
          expect(response.status).to eq 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be_nil
        end

        it 'receives "page=fake" as an invalid params' do
          expect(json_body['error']['invalid_params']).to eq 'page=fake'
        end
      end
    end

    describe 'sorting' do
      context 'with valid column name "id"' do
        it 'sorts the users by "id desc"' do
          get '/api/users?sort=id&dir=desc'
          expect(json_body['data'].first['id']).to eq john.id
          expect(json_body['data'].last['id']).to eq admin_user.id
        end
      end

      context 'with invalid column name "fid"' do
        before { get '/api/users?sort=fid&dir=asc' }

        it 'receives HTTP status 400' do
          expect(response.status).to eq 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be_nil
        end

        it 'receives "sort=fid" as an invalid param' do
          expect(json_body['error']['invalid_params']).to eq 'sort=fid'
        end
      end
    end

    describe 'filtering' do
      context 'with valid filtering param "q[given_name_cont]=Daniel"' do
        it 'receives "Daniel Boldan" user' do
          get('/api/users?q[given_name_cont]=Daniel')

          expect(json_body['data'].first['id']).to eq daniel.id
          expect(json_body['data'].size).to eq 1
        end
      end

      context 'with invalid filtering param "q[fgiven_name_cont]=Daniel"' do
        before { get('/api/users?q[fgiven_name_cont]=Daniel') }

        it 'get "400 Bad Request" back' do
          expect(response.status).to eq 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be_nil
        end

        it 'receives "q[fgiven_name_cont]=Daniel" as an invalid param' do
          expect(json_body['error']['invalid_params']).to eq 'q[fgiven_name_cont]=Daniel'
        end
      end
    end
  end

  describe 'GET /api/users/:id' do
    context 'with existing resource' do
      before { get "/api/users/#{daniel.id}"}

      it 'gets HTTP status 200' do
        expect(response.status).to eq 200
      end

      it 'receives the "daniel" user as JSON' do
        expected = { data: UserPresenter.new(daniel, {}).fields.embeds }
        expect(response.body).to eq expected.to_json
      end
    end

    context 'with nonexistent resource' do
      it 'gets HTTP status 404' do
        get '/api/users/342323'
        expect(response.status).to eq 404
      end
    end
  end

  describe 'POST /api/users' do
    before { post '/api/users', params: { data: params } }

    context 'with valid parameters' do
      let(:params) { attributes_for(:user, email: 'new@sandra.app') }

      it 'gets HTTP status 201' do
        expect(response.status).to eq 201
      end

      it 'receives the newly created resource' do
        expect(json_body['data']['given_name']).to eq(daniel.given_name)
      end

      it 'adds a record to the database' do
        expect(User.count).to eq 2
      end

      it 'gets the new resource location in the Location header' do
        expect(response.headers['Location']).to eq("http://www.example.com/api/users/#{User.last.id}")
      end

      it 'delivers confirmation email mailer' do
        expect(ActionMailer::Base.deliveries.count).to be 1
      end
    end

    context 'with invalid parameters' do
      let(:params) { attributes_for(:user, email: '')}

      it 'gets HTTP status 422' do
        expect(response.status).to eq 422
      end

      it 'receives an error details' do
        error = { 'email'=>["can't be blank", "is invalid"] }
        expect(json_body['error']['invalid_params']).to eq(error)
      end

      it 'does not add a record to database' do
        expect(User.count).to eq 1
      end
    end
  end

  describe 'PATCH /api/users/:id' do
    before { patch "/api/users/#{daniel.id}", params: { data: params } }

    context 'with valid parameters' do
      let(:params) { { given_name: 'Vasile' } }

      it 'gets HTTP status 200' do
        expect(response.status).to eq 200
      end

      it 'receives the updated resource' do
        expect(json_body['data']['given_name']).to eq('Vasile')
      end

      it 'updates the record in the database' do
        expect(User.first.given_name).to eq 'Super'
      end
    end

    context 'with invalid parameters' do
      let(:params) { { email: '' } }

      it 'gets HTTP status 422' do
        expect(response.status).to eq 422
      end

      it 'receives an error details' do
        error = { 'email' => ["can't be blank", "is invalid"] }
        expect(json_body['error']['invalid_params']).to eq(error)
      end

      it 'does not update the record in database' do
        expect(User.first.email).to eq('admin@sandra.app')
      end
    end
  end

  describe 'DELETE /api/users/:id' do
    context 'with existing resource' do
      before { delete "/api/users/#{daniel.id}" }

      it 'receives HTTP status 204' do
        expect(response.status).to eq 204
      end

      it 'delete record from database' do
        expect(User.count).to eq 1
      end
    end

    context 'with nonexistent resource' do
      before { delete '/api/users/32783278' }

      it 'gets HTTP status 404' do
        expect(response.status).to eq 404
      end
    end
  end
end