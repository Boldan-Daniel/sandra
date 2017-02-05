require 'rails_helper'

RSpec.describe 'Publishers', type: :request do
  let(:packtpub) { create :packtpub}
  let(:dev_media) { create :dev_media }
  let(:super_books) { create :super_books }

  let(:publishers) { [packtpub, dev_media, super_books] }

  describe 'GET /api/publishers' do
    before { publishers }

    context 'default behavior' do
      before { get '/api/publishers' }

      it 'receives HTTP status 200' do
        expect(response.status).to eq 200
      end

      it 'receives a json with the "data" root key' do
        expect(json_body['data']).to_not be_nil
      end

      it 'receives all 3 publishers' do
        expect(json_body['data'].size).to eq 3
      end
    end

    describe 'field picking' do
      context 'with the fields parameter' do
        before { get '/api/publishers?fields=id,name'}

        it 'gets publishers with only the id and name keys' do
          json_body['data'].each do |publisher|
            expect(publisher.keys).to eq ['id', 'name']
          end
        end
      end

      context 'without the fields parameter' do
        before { get '/api/publishers' }

        it 'gets publishers with all the fields specified in the presenter' do
          json_body['data'].each do |publisher|
            expect(publisher.keys).to eq PublisherPresenter.build_attributes.map(&:to_s)
          end
        end
      end

      context 'with invalid fields parameter "fields=fid,name"' do
        before { get '/api/publishers?fields=fid,name'}

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

    describe 'embed picking' do
      context 'with valid "embed" parameter' do
        let!(:agile_rails) { create :agile_rails, publisher_id: packtpub.id }

        before { get '/api/publishers?embed=books' }

        it 'gets the publishers with their books embedded' do
          expect(json_body['data'].first['books'].first['title']).to eq agile_rails.title
        end
      end

      context 'with invalid "embed" relation "fake"' do
        before { get '/api/publishers?embed=fake' }

        it 'gets "400 Bad Request" back' do
          expect(response.status).to eq 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be nil
        end

        it 'receives "embed=fake" as an invalid param' do
          expect(json_body['error']['invalid_params']).to eq 'embed=fake'
        end
      end
    end

    describe 'pagination' do
      context 'when asking for the first page' do
        before { get '/api/publishers?page=1&per=2' }

        it 'receives HTTP status 200' do
          expect(response.status).to eq 200
        end

        it 'receives only 2 publishers' do
          expect(json_body['data'].size).to eq 2
        end

        it 'receives a response with the Link header' do
          expect(response.headers['Link'].split(', ').first).to eq (
                                                                       '<http://www.example.com/api/publishers?page=2&per=2>; rel="next"'
                                                                   )
        end
      end

      context 'when asking for the next page' do
        before { get '/api/publishers?page=2&per=2' }

        it 'receives HTTP status 200' do
          expect(response.status).to eq 200
        end

        it 'receives only one publisher' do
          expect(json_body['data'].size).to eq 1
        end
      end

      context 'when sending invalid "page" and "per" parameters' do
        before { get '/api/publishers?page=fake&per=10' }

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
        it 'sorts the publishers by "id desc"' do
          get '/api/publishers?sort=id&dir=desc'
          expect(json_body['data'].first['id']).to eq super_books.id
          expect(json_body['data'].last['id']).to eq packtpub.id
        end
      end

      context 'with invalid column name "fid"' do
        before { get '/api/publishers?sort=fid&dir=asc' }

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
      context 'with valid filtering param "q[name_cont]=ack"' do
        it 'receives "Packtpub"' do
          get('/api/publishers?q[name_cont]=ack')

          expect(json_body['data'].first['id']).to eq packtpub.id
          expect(json_body['data'].size).to eq 1
        end
      end

      context 'with invalid filtering param "q[fake_cont]=ack"' do
        before { get('/api/publishers?q[fake_cont]=ack') }

        it 'get "400 Bad Request" back' do
          expect(response.status).to eq 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be_nil
        end

        it 'receives "q[fake_cont]=ack" as an invalid param' do
          expect(json_body['error']['invalid_params']).to eq 'q[fake_cont]=ack'
        end
      end
    end
  end

  describe 'GET /api/publishers/:id' do
    context 'with existing resource' do
      before { get "/api/publishers/#{packtpub.id}"}

      it 'gets HTTP status 200' do
        expect(response.status).to eq 200
      end

      it 'receives the "packtpub" publisher as JSON' do
        expected = { data: PublisherPresenter.new(packtpub, {}).fields.embeds }
        expect(response.body).to eq expected.to_json
      end
    end

    context 'with nonexistent resource' do
      it 'gets HTTP status 404' do
        get '/api/publishers/342323'
        expect(response.status).to eq 404
      end
    end
  end

  describe 'POST /api/publishers' do
    before { post '/api/publishers', params: { data: params } }

    context 'with valid parameters' do
      let(:params) { attributes_for :packtpub }

      it 'gets HTTP status 201' do
        expect(response.status).to eq 201
      end

      it 'receives the newly created resource' do
        expect(json_body['data']['name']).to eq(packtpub.name)
      end

      it 'adds a record to the database' do
        expect(Publisher.count).to eq 1
      end

      it 'gets the new resource location in the Location header' do
        expect(response.headers['Location']).to eq("http://www.example.com/api/publishers/#{Publisher.first.id}")
      end
    end

    context 'with invalid parameters' do
      let(:params) { attributes_for(:packtpub, name: '')}

      it 'gets HTTP status 422' do
        expect(response.status).to eq 422
      end

      it 'receives an error details' do
        error = { 'name'=>["can't be blank"] }
        expect(json_body['error']['invalid_params']).to eq(error)
      end

      it 'does not add a record to database' do
        expect(Publisher.count).to eq 0
      end
    end
  end

  describe 'PATCH /api/publishers/:id' do
    before { patch "/api/publishers/#{packtpub.id}", params: { data: params } }

    context 'with valid parameters' do
      let(:params) { { name: 'New publisher' } }

      it 'gets HTTP status 200' do
        expect(response.status).to eq 200
      end

      it 'receives the updated resource' do
        expect(json_body['data']['name']).to eq('New publisher')
      end

      it 'updates the record in the database' do
        expect(Publisher.first.name).to eq 'New publisher'
      end
    end

    context 'with invalid parameters' do
      let(:params) { { name: '' } }

      it 'gets HTTP status 422' do
        expect(response.status).to eq 422
      end

      it 'receives an error details' do
        error = { 'name' => ["can't be blank"] }
        expect(json_body['error']['invalid_params']).to eq(error)
      end

      it 'does not update the record in database' do
        expect(Publisher.first.name).to eq('Packtpub')
      end
    end
  end

  describe 'DELETE /api/publishers/:id' do
    context 'with existing resource' do
      before { delete "/api/publishers/#{packtpub.id}" }

      it 'receives HTTP status 204' do
        expect(response.status).to eq 204
      end

      it 'delete record from database' do
        expect(Publisher.count).to eq 0
      end
    end

    context 'with nonexistent resource' do
      before { delete '/api/publishers/32783278' }

      it 'gets HTTP status 404' do
        expect(response.status).to eq 404
      end
    end
  end
end