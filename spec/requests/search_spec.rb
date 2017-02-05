require 'rails_helper'

RSpec.describe 'Search', type: :request do
  let(:agile_rails) { create :agile_rails }
  let(:practical_ruby) { create :practical_ruby }
  let(:ecommerce_rails) { create :ecommerce_rails }

  let(:books) { [agile_rails, practical_ruby, ecommerce_rails] }

  describe 'GET /api/search/:text' do
    before { books }

    context 'with text "ruby"' do
      before { get '/api/search/ruby' }

      it 'receives HTTP status 200' do
        expect(response.status).to eq 200
      end

      it 'receives a "ecommerce_rails" document' do
        expect(json_body['data'][0]['searchable_id']).to eq ecommerce_rails.id
        expect(json_body['data'][0]['searchable_type']).to eq 'Book'
      end

      it 'receives a "agile_rails" document' do
        expect(json_body['data'][1]['searchable_id']).to eq agile_rails.id
        expect(json_body['data'][1]['searchable_type']).to eq 'Book'
      end

      it 'receives a "practical_ruby" document' do
        expect(json_body['data'][2]['searchable_id']).to eq practical_ruby.id
        expect(json_body['data'][2]['searchable_type']).to eq 'Book'
      end

      it 'receives a "sam_ruby" document' do
        expect(json_body['data'][3]['searchable_id']).to eq ecommerce_rails.author.id
        expect(json_body['data'][3]['searchable_type']).to eq 'Author'
      end

    end
  end
end