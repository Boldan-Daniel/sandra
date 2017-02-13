require 'rails_helper'

RSpec.describe DownloadPolicy do
  subject { described_class }

  permissions :show? do
    context 'when admin' do
      it 'grants access' do
        user, admin = build(:user), build(:admin)
        expect(subject).to permit(admin, Purchase.new(user: user))
      end
    end

    context 'when not admin' do
      it 'denies access if the user did not buy the book' do
        expect(subject).not_to permit(create(:user), create(:book))
      end

      it 'grants access if the user has bought the book' do
        user, book = create(:user), create(:book)
        create(:purchase, user: user, book: book)
        expect(subject).to permit(user, book)
      end
    end
  end
end