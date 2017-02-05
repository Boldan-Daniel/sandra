require 'rails_helper'

RSpec.describe 'Authors', type: :request do
  let(:sam_ruby) { create :sam_ruby}
  let(:jarkko_laine) { create :jarkko_laine }
  let(:topher_cyll) { create :topher_cyll }

  let(:authors) { [sam_ruby, jarkko_laine, topher_cyll] }

  describe 'GET /api/authors' do
    before { authors }

    context 'default behavior' do
      before { get '/api/authors' }

      it 'receives HTTP status 200' do
        expect(response.status).to eq 200
      end

      it 'receives a json with the "data" root key' do
        expect(json_body['data']).to_not be_nil
      end

      it 'receives all 3 authors' do
        expect(json_body['data'].size).to eq 3
      end
    end

    describe 'field picking' do
      context 'with the fields parameter' do
        before { get '/api/authors?fields=id,given_name,family_name'}

        it 'gets authors with only the id, given name and family name keys' do
          json_body['data'].each do |author|
            expect(author.keys).to eq ['id', 'given_name', 'family_name']
          end
        end
      end

      context 'without the fields parameter' do
        before { get '/api/authors' }

        it 'gets authors with all the fields specified in the presenter' do
          json_body['data'].each do |author|
            expect(author.keys).to eq AuthorPresenter.build_attributes.map(&:to_s)
          end
        end
      end

      context 'with invalid fields parameter "fields=fid,given_name"' do
        before { get '/api/authors?fields=fid,given_name'}

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
        let(:agile_rails) { create :agile_rails, author_id: sam_ruby.id }

        before { get '/api/authors?embed=books' }

        it 'gets the authors with their books embedded' do
          expect(json_body['data'].first['id']).to eq agile_rails.id
        end
      end

      context 'with invalid "embed" relation "fake"' do
        before { get '/api/authors?embed=fake,author' }

        it 'gets "400 Bad Request" back' do
          expect(response.status).to eq 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be nil
        end

        it 'receives "fields=fid" as an invalid param' do
          expect(json_body['error']['invalid_params']).to eq 'embed=fake'
        end
      end
    end

    describe 'pagination' do
      context 'when asking for the first page' do
        before { get '/api/authors?page=1&per=2' }

        it 'receives HTTP status 200' do
          expect(response.status).to eq 200
        end

        it 'receives only 2 authors' do
          expect(json_body['data'].size).to eq 2
        end

        it 'receives a response with the Link header' do
          expect(response.headers['Link'].split(', ').first).to eq (
                                                                       '<http://www.example.com/api/authors?page=2&per=2>; rel="next"'
                                                                   )
        end
      end

      context 'when asking for the next page' do
        before { get '/api/authors?page=2&per=2' }

        it 'receives HTTP status 200' do
          expect(response.status).to eq 200
        end

        it 'receives only one author' do
          expect(json_body['data'].size).to eq 1
        end
      end

      context 'when sending invalid "page" and "per" parameters' do
        before { get '/api/authors?page=fake&per=10' }

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
        it 'sorts the authors by "id desc"' do
          get '/api/authors?sort=id&dir=desc'
          expect(json_body['data'].first['id']).to eq topher_cyll.id
          expect(json_body['data'].last['id']).to eq sam_ruby.id
        end
      end

      context 'with invalid column name "fid"' do
        before { get '/api/authors?sort=fid&dir=asc' }

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
      context 'with valid filtering param "q[given_name_cont]=am"' do
        it 'receives "Sam Ruby"' do
          get('/api/authors?q[given_name_cont]=am')

          expect(json_body['data'].first['id']).to eq sam_ruby.id
          expect(json_body['data'].size).to eq 1
        end
      end

      context 'with invalid filtering param "q[fake_cont]=am"' do
        before { get('/api/authors?q[fake_cont]=am') }

        it 'get "400 Bad Request" back' do
          expect(response.status).to eq 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be_nil
        end

        it 'receives "q[fake_cont]=am" as an invalid param' do
          expect(json_body['error']['invalid_params']).to eq 'q[fake_cont]=am'
        end
      end
    end
  end

  describe 'GET /api/authors/:id' do
    context 'with existing resource' do
      before { get "/api/authors/#{sam_ruby.id}"}

      it 'gets HTTP status 200' do
        expect(response.status).to eq 200
      end

      it 'receives the "sam_ruby" author as JSON' do
        expected = { data: AuthorPresenter.new(sam_ruby, {}).fields.embeds }
        expect(response.body).to eq expected.to_json
      end
    end

    context 'with nonexistent resource' do
      it 'gets HTTP status 404' do
        get '/api/authors/342323'
        expect(response.status).to eq 404
      end
    end
  end

  describe 'POST /api/authors' do
    before { post '/api/authors', params: { data: params } }

    context 'with valid parameters' do
      let(:params) { attributes_for :sam_ruby }

      it 'gets HTTP status 201' do
        expect(response.status).to eq 201
      end

      it 'receives the newly created resource' do
        expect(json_body['data']['given_name']).to eq(sam_ruby.given_name)
      end

      it 'adds a record to the database' do
        expect(Author.count).to eq 1
      end

      it 'gets the new resource location in the Location header' do
        expect(response.headers['Location']).to eq("http://www.example.com/api/authors/#{Author.first.id}")
      end
    end

    context 'with invalid parameters' do
      let(:params) { attributes_for(:sam_ruby, given_name: '')}

      it 'gets HTTP status 422' do
        expect(response.status).to eq 422
      end

      it 'receives an error details' do
        error = { 'given_name'=>["can't be blank"] }
        expect(json_body['error']['invalid_params']).to eq(error)
      end

      it 'does not add a record to database' do
        expect(Author.count).to eq 0
      end
    end
  end

  describe 'PATCH /api/authors/:id' do
    before { patch "/api/authors/#{sam_ruby.id}", params: { data: params } }

    context 'with valid parameters' do
      let(:params) { { given_name: 'Daniel' } }

      it 'gets HTTP status 200' do
        expect(response.status).to eq 200
      end

      it 'receives the updated resource' do
        expect(json_body['data']['given_name']).to eq('Daniel')
      end

      it 'updates the record in the database' do
        expect(Author.first.given_name).to eq 'Daniel'
      end
    end

    context 'with invalid parameters' do
      let(:params) { { given_name: '' } }

      it 'gets HTTP status 422' do
        expect(response.status).to eq 422
      end

      it 'receives an error details' do
        error = { 'given_name' => ["can't be blank"] }
        expect(json_body['error']['invalid_params']).to eq(error)
      end

      it 'does not update the record in database' do
        expect(Author.first.given_name).to eq('Sam')
      end
    end
  end

  describe 'DELETE /api/authors/:id' do
    context 'with existing resource' do
      before { delete "/api/authors/#{sam_ruby.id}" }

      it 'receives HTTP status 204' do
        expect(response.status).to eq 204
      end

      it 'delete record from database' do
        expect(Author.count).to eq 0
      end
    end

    context 'with nonexistent resource' do
      before { delete '/api/authors/32783278' }

      it 'gets HTTP status 404' do
        expect(response.status).to eq 404
      end
    end
  end
end