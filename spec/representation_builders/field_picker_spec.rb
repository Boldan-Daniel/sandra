require 'rails_helper'

RSpec.describe 'FieldPicker' do
  let(:agile_rails) { create(:agile_rails) }
  let(:params) { { fields: 'id,title,subtitle' } }
  let(:presenter) { BookPresenter.new(rails_tutorial, params) }
  let(:field_picker) { FieldPicker.new(presenter) }

  before do
    allow(BookPresenter).to(receive(:build_attributes).and_return(['id', 'title', 'author_id']))
  end

  describe '#pick' do
    context 'with the "fields" parameter containing "id,title,subtitle"' do
      it 'updates the presenter "data" with the book "id" and "title"' do
        expect(field_picker.pick.data).to eq({
            'id' => agile_rails.id,
            'title' => 'Ruby on Rails Tutorial' })
      end
    end

    context 'with overriding method defined in presenter' do
      before { presenter.class.send(:define_method, :title) { 'Overriden!' } }

      it 'updates the presenter "data" with the title "Overridden!"' do
        expect(field_picker.pick.data).to eq({
            'id' => agile_rails.id,
            'title' => 'Overriden!' })
      end

      after { presenter.class.send(:remove_method, :title) }
    end

    context 'with no "fields" parameter' do
      let(:params) { {} }

      it 'updates "data" with the fields ("id", "title", "author_id")' do
        expect(field_picker.send(:pick).data).to eq({
            'id' => agile_rails.id,
            'title' => 'Ruby on Rails Tutorial',
            'author_id' => agile_rails.author.id })
      end
    end
  end
end