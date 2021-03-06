require 'rails_helper'

RSpec.describe BasePresenter do
  class Presenter < BasePresenter; end
  let(:presenter) { Presenter.new('some_object', { some_params: 'something' }) }

  describe '#initialize' do
    it 'sets the "object" variable with "some_object"' do
      expect(presenter.object).to eq 'some_object'
    end

    it 'sets the "params" variable with { some_params: "something" }' do
      expect(presenter.params).to eq({ some_params: 'something' })
    end

    it 'initialize "data" as a HashWithIndifferentAccess' do
      expect(presenter.data).to be_kind_of(HashWithIndifferentAccess)
    end
  end

  describe '#as_json' do
    it 'allows the serialization of "data" to json' do
      presenter.data = { some_params: 'something' }
      expect(presenter.to_json).to eq '{"some_params":"something"}'
    end
  end

  describe '.build_with' do
    it 'stores ["id", "title"] in "build_attributes"' do
      Presenter.build_with :id, :title
      expect(Presenter.build_attributes).to eq ['id', 'title']
    end
  end

  describe '.related_to' do
    it 'stores the correct value' do
      Presenter.related_to :author, :publisher
      expect(Presenter.relations).to eq ['author', 'publisher']
    end
  end

  describe '.sort_by' do
    it 'stores the correct value' do
      Presenter.sort_by :id, :title
      expect(Presenter.sort_attributes).to eq ['id', 'title']
    end
  end

  describe '.filter_by' do
    it 'stores the correct value' do
      Presenter.filter_by :title
      expect(Presenter.filter_attributes).to eq ['title']
    end
  end
end
