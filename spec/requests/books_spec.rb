require 'rails_helper'

RSpec.describe 'Books', type: :request do

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

  end
end