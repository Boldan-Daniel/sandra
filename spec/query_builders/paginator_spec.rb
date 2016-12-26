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
end