require 'rails_helper'

RSpec.describe EmbedPicker do
  let(:author) { create(:author) }

  let(:agile_rails) { create(:agile_rails, author_id: author.id) }
  let(:practical_ruby)  { create :practical_ruby, author_id: author.id }

  let(:params) { { } }
  let(:embed_picker) { EmbedPicker.new(presenter) }

  describe '#embed' do
    context 'with books (many-to-one) as the resource' do
      let(:presenter) { BookPresenter.new(practical_ruby, params) }

      before do
        allow(BookPresenter).to(receive(:relations)).and_return(['author'])
      end

      context 'with no "embed" parameter' do
        it 'returns the "data" hash without changing it' do
          expect(embed_picker.embed.data).to eq(presenter.data)
        end
      end

      context 'with invalid relation something' do
        let(:params) { { embed: 'something' } }

        it 'raises a RepresentationBuilderError' do
          expect { embed_picker.embed }.to raise_error(RepresentationBuilderError)
        end
      end

      context 'with the "embed" parameter containing "author"' do
        let(:params) { { embed: 'author' } }

        it 'embeds the "author" to data' do
          expect(embed_picker.embed.data[:author]).to eq({
              'id' => practical_ruby.author.id,
              'given_name' => 'John',
              'family_name' => 'Doe',
              'created_at' => practical_ruby.author.created_at,
              'updated_at' => practical_ruby.author.updated_at
                                                         })
        end
      end

      context 'with the "embed" parameter containing "books"' do
        let(:params) { { embed: 'books' } }
        let(:presenter) { AuthorPresenter.new(author, params) }

        before do
          agile_rails && practical_ruby
          allow(AuthorPresenter).to(
              receive(:relations).and_return(['books'])
          )
        end

        it 'embeds the "books" data' do
          expect(embed_picker.embed.data[:books].size).to eq(2)
          expect(embed_picker.embed.data[:books].first['id']).to eq(agile_rails.id)
          expect(embed_picker.embed.data[:books].last['id']).to eq(practical_ruby.id)
        end
      end

    end
  end
end