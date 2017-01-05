require 'rails_helper'

RSpec.describe Filter do
  let(:agile_rails)     { create :agile_rails }
  let(:practical_ruby)  { create :practical_ruby }
  let(:ecommerce_rails) { create :ecommerce_rails }
  let(:books)           { [agile_rails, practical_ruby, ecommerce_rails] }

  let(:scope)    { Book.all }
  let(:params)   { {} }
  let(:filter)   { Filter.new(scope, params) }
  let(:filtered) { filter.filter }

  before do
    allow(BookPresenter).to(
        receive(:filter_attributes).and_return(['id', 'title', 'released_on'])
    )
    books
  end

  describe '#filter' do
    context 'without any parameters' do
      it 'returns the scope unchanged' do
        expect(filtered).to eq scope
      end
    end

    context 'with valid parameters' do
      context 'with "title_eq=Ruby on Rails Tutorial"' do
        let(:params) { { 'q' => { 'title_eq' => 'Ruby on Rails Tutorial' } } }

        it 'gets only "Ruby on Rails Tutorial" back' do
          expect(filtered.first.id).to eq agile_rails.id
          expect(filtered.size).to eq 1
        end
      end

      context 'with "title_cont=Tutorial"' do
        let(:params) { { 'q' => { 'title_cont' => 'Tutorial' } } }

        it 'gets only "Ruby on Rails Tutorial" back' do
          expect(filtered.first.id).to eq agile_rails.id
          expect(filtered.size).to eq 1
        end
      end

      context 'with "title_notcont=Tutorial"' do
        let(:params) { { 'q' => { 'title_notcont' => 'Tutorial' } } }

        it 'gets only "Practical Ruby Projects" back' do
          expect(filtered.first.id).to eq practical_ruby.id
          expect(filtered.size).to eq 2
        end
      end

      context 'with "title_start=Ruby"' do
        let(:params) { { 'q' => { 'title_start' => 'Ruby' } } }

        it 'gets only "Ruby on Rails Tutorial"' do
          expect(filtered.first.id).to eq agile_rails.id
          expect(filtered.size).to eq 1
        end
      end

      context 'with "title_end=Projects"' do
        let(:params) { { 'q' => { 'title_end' => 'Projects' } } }

        it 'gets only "Practical Ruby Projects"' do
          expect(filtered.first.id).to eq practical_ruby.id
          expect(filtered.size).to eq 1
        end
      end

      context 'with "released_on_lt=2016-10-10"' do
        let(:params) { { 'q' => { 'released_on_lt' => '2016-10-10' } } }

        it 'gets only "Practical Ruby Projects"' do
          expect(filtered.first.id).to eq agile_rails.id
          expect(filtered.size).to eq 1
        end
      end

      context 'with "released_on_gt=2016-10-10"' do
        let(:params) { { 'q' => { 'released_on_gt' => '2016-10-10' } } }

        it 'gets only "Practical Ruby Projects"' do
          expect(filtered.first.id).to eq practical_ruby.id
          expect(filtered.size).to eq 2
        end
      end
    end

    context 'with invalid parameters' do
      context 'with invalid column name "fid"' do
        let(:params) { { 'q' => { 'fid_gt' => '2' } } }

        it 'raises a "QueryBuilderError" exception' do
          expect { filtered }.to raise_error(QueryBuilderError)
        end
      end

      context 'with invalid predicate "gtz"' do
        let(:params) { { 'q' => { 'id_gtz' => '2' } } }

        it 'raises a "QueryBuilderError" exception' do
          expect { filtered }.to raise_error(QueryBuilderError)
        end
      end
    end
  end
end