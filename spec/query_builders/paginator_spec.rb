require 'rails_helper'

RSpec.describe Paginator do
  let(:agile_rails) { create :agile_rails }
  let(:practical_ruby) { create :practical_ruby }
  let(:ecommerce_rails) { create :ecommerce_rails }
  let(:books) { [agile_rails, practical_ruby, ecommerce_rails] }

  let(:scope) { Book.all }
  let(:params) { { 'page' => 1, 'per' => 2 } }

  let(:paginator) { Paginator.new scope, params, 'url' }
  let(:paginated) { paginator.paginate }

  before do
    books
  end

  describe '#paginate' do
    it 'paginates the collection with 2 books' do
      expect(paginated.size).to eq 2
    end

    it 'contains agile_rails as the first paginated item' do
      expect(paginated.first).to eq agile_rails
    end

    it 'contains practical_ruby as the last paginated item' do
      expect(paginated.last).to eq practical_ruby
    end
  end

  describe '#links' do
    let(:links) { paginator.links.split(', ') }

    context 'when first page' do
      it 'builds the "next" relation link' do
        expect(links.first).to eq '<url?page=2&per=2>; rel="next"'
      end

      it 'builds the "last" relation link' do
        expect(links.last).to eq '<url?page=2&per=2>; rel="last"'
      end
    end

    context 'when last page' do
      let(:params) { { 'page' => '2', 'per' => '2' } }

      it 'builds the "first" relation link' do
        expect(links.first).to eq '<url?page=1&per=2>; rel="first"'
      end

      it 'builds the "prev" relation link' do
        expect(links.last).to eq '<url?page=1&per=2>; rel="prev"'
      end
    end
  end
end