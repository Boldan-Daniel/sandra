require 'rails_helper'

RSpec.describe 'Books', type: :request do
  before do
    allow_any_instance_of(BooksController).to(
        receive(:validate_auth_scheme).and_return(true)
    )

    allow_any_instance_of(BooksController).to(
        receive(:authenticate_client).and_return(true)
    )
  end

  let(:agile_rails) { create :agile_rails }
  let(:practical_ruby) { create :practical_ruby }
  let(:ecommerce_rails) { create :ecommerce_rails }

  let(:books) { [agile_rails, practical_ruby, ecommerce_rails] }

  describe 'GET /api/books' do
    before { books }

    context 'default behavior' do
      before { get '/api/books' }

      it 'receives HTTP status 200' do
        expect(response.status).to eq 200
      end

      it 'receives a json with the "data" root key' do
        expect(json_body['data']).to_not be_nil
      end

      it 'receives all 3 books' do
        expect(json_body['data'].size).to eq 3
      end
    end

    describe 'field picking' do
      context 'with the fields parameter' do
        before { get '/api/books?fields=id,title,author_id'}

        it 'gets books with only the id, title and author_id keys' do
          json_body['data'].each do |book|
            expect(book.keys).to eq ['id', 'title', 'author_id']
          end
        end
      end

      context 'without the fields parameter' do
        before { get '/api/books' }

        it 'gets books with all the fields specified in the presenter' do
          json_body['data'].each do |book|
            expect(book.keys).to eq BookPresenter.build_attributes.map(&:to_s)
          end
        end
      end

      context 'with invalid fields parameter "fields=fid,title"' do
        before { get '/api/books?fields=fid,title'}

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
        before { get '/api/books?embed=author' }

        it 'gets the books with their authors embedded' do
          json_body['data'].each do |book|
            expect(book['author'].keys).to eq(['id', 'given_name', 'family_name', 'created_at', 'updated_at'])
          end
        end
      end

      context 'with invalid "embed" relation "fake"' do
        before { get '/api/books?embed=fake,author' }

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
        before { get '/api/books?page=1&per=2' }

        it 'receives HTTP status 200' do
          expect(response.status).to eq 200
        end

        it 'receives only 2 books' do
          expect(json_body['data'].size).to eq 2
        end

        it 'receives a response with the Link header' do
          expect(response.headers['Link'].split(', ').first).to eq (
            '<http://www.example.com/api/books?page=2&per=2>; rel="next"'
                                                                   )
        end
      end

      context 'when asking for the next page' do
        before { get '/api/books?page=2&per=2' }

        it 'receives HTTP status 200' do
          expect(response.status).to eq 200
        end

        it 'receives only one book' do
          expect(json_body['data'].size).to eq 1
        end
      end

      context 'when sending invalid "page" and "per" parameters' do
        before { get '/api/books?page=fake&per=10' }

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
        it 'sorts the books by "id desc"' do
          get '/api/books?sort=id&dir=desc'
          expect(json_body['data'].first['id']).to eq ecommerce_rails.id
          expect(json_body['data'].last['id']).to eq agile_rails.id
        end
      end

      context 'with invalid column name "fid"' do
        before { get '/api/books?sort=fid&dir=asc' }

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
      context 'with valid filtering param "q[title_cont]=Tutorial"' do
        it 'receives "Ruby on Rails Tutorial"' do
          get('/api/books?q[title_cont]=Tutorial')

          expect(json_body['data'].first['id']).to eq agile_rails.id
          expect(json_body['data'].size).to eq 1
        end
      end

      context 'with invalid filtering param "q[ftitle_cont]=Tutorial"' do
        before { get('/api/books?q[ftitle_cont]=Tutorial') }

        it 'get "400 Bad Request" back' do
          expect(response.status).to eq 400
        end

        it 'receives an error' do
          expect(json_body['error']).to_not be_nil
        end

        it 'receives "q[ftitle_cont]=Tutorial" as an invalid param' do
          expect(json_body['error']['invalid_params']).to eq 'q[ftitle_cont]=Tutorial'
        end
      end
    end
  end

  describe 'GET /api/books/:id' do
    context 'with existing resource' do
      before { get "/api/books/#{agile_rails.id}"}

      it 'gets HTTP status 200' do
        expect(response.status).to eq 200
      end

      it 'receives the "agile_rails" book as JSON' do
        expected = { data: BookPresenter.new(agile_rails, {}).fields.embeds }
        expect(response.body).to eq expected.to_json
      end
    end

    context 'with nonexistent resource' do
      it 'gets HTTP status 404' do
        get '/api/books/342323'
        expect(response.status).to eq 404
      end
    end
  end

  describe 'POST /api/books' do
    let(:author) { create(:author) }

    before { post '/api/books', params: { data: params } }

    context 'with valid parameters' do
      let(:params) { attributes_for(:agile_rails,
                                    isbn_10: '1235548790',
                                    isbn_13: '9875439654416',
                                    author_id: author.id) }

      it 'gets HTTP status 201' do
        expect(response.status).to eq 201
      end

      it 'receives the newly created resource' do
        expect(json_body['data']['title']).to eq(agile_rails.title)
      end

      it 'adds a record to the database' do
        expect(Book.count).to eq 1
      end

      it 'gets the new resource location in the Location header' do
        expect(response.headers['Location']).to eq("http://www.example.com/api/books/#{Book.first.id}")
      end
    end

    context 'with invalid parameters' do
      let(:params) { attributes_for(:agile_rails,
                                    isbn_10: '1235548790',
                                    isbn_13: '9875439654416',
                                    title: '')}

      it 'gets HTTP status 422' do
        expect(response.status).to eq 422
      end

      it 'receives an error details' do
        error = {'title'=>["can't be blank"], 'author'=>["can't be blank"] }
        expect(json_body['error']['invalid_params']).to eq(error)
      end

      it 'does not add a record to database' do
        expect(Book.count).to eq 0
      end
    end
  end

  describe 'PATCH /api/books/:id' do
    before { patch "/api/books/#{agile_rails.id}", params: { data: params } }

    context 'with valid parameters' do
      let(:params) { { title: 'New agile rails title' } }

      it 'gets HTTP status 200' do
        expect(response.status).to eq 200
      end

      it 'receives the updated resource' do
        expect(json_body['data']['title']).to eq('New agile rails title')
      end

      it 'updates the record in the database' do
        expect(Book.first.title).to eq 'New agile rails title'
      end
    end

    context 'with invalid parameters' do
      let(:params) { { title: '' } }

      it 'gets HTTP status 422' do
        expect(response.status).to eq 422
      end

      it 'receives an error details' do
        error = { 'title' => ["can't be blank"] }
        expect(json_body['error']['invalid_params']).to eq(error)
      end

      it 'does not update the record in database' do
        expect(Book.first.title).to eq('Ruby on Rails Tutorial')
      end
    end
  end

  describe 'DELETE /api/books/:id' do
    context 'with existing resource' do
      before { delete "/api/books/#{agile_rails.id}" }

      it 'receives HTTP status 204' do
        expect(response.status).to eq 204
      end

      it 'delete record from database' do
        expect(Book.count).to eq 0
      end
    end

    context 'with nonexistent resource' do
      before { delete '/api/books/32783278' }

      it 'gets HTTP status 404' do
        expect(response.status).to eq 404
      end
    end
  end
end