require 'rails_helper'

RSpec.describe Sorter do

  let(:agile_rails)     { create :agile_rails }
  let(:practical_ruby)  { create :practical_ruby }
  let(:ecommerce_rails) { create :ecommerce_rails }
  let(:books)           { [agile_rails, practical_ruby, ecommerce_rails] }

  let(:scope)  { Book.all }
  let(:params) { HashWithIndifferentAccess.new({ sort: 'id', dir: 'desc' }) }
  let(:sorter) { Sorter.new scope, params }
  let(:sorted) { sorter.sort }

  before do
    allow(BookPresenter).to(
        receive(:sort_attributes).and_return(['id', 'title'])
    )
    books
  end

  describe '#sort' do
    context 'without any parameters' do
      let(:params) { {} }
      it 'return the scope unchanged' do
        expect(sorted).to eq scope
      end
    end

    context 'with valid parameters' do
      it 'sorts the collection by "id desc"' do
        expect(sorted.first.id).to eq ecommerce_rails.id
        expect(sorted.last.id).to eq agile_rails.id
      end

      it 'sorts the collection by "title asc"' do
        expect(sorted.first).to eq ecommerce_rails
        expect(sorted.last).to eq agile_rails
      end
    end

    context 'with invalid parameters' do
      let(:params) { HashWithIndifferentAccess.new({ sort: 'fid', dir: 'desc' }) }
      it 'raisees a QueryBuilderError exception' do
        expect { sorted }.to raise_error(QueryBuilderError)
      end
    end
  end
end