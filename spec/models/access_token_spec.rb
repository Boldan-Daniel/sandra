require 'rails_helper'

RSpec.describe AccessToken, type: :model do
  let(:access_token) { create(:access_token) }

  it 'has a valid factory' do
    expect(build(:access_token)).to be_valid
  end

  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:api_key) }

  describe '#authenticate' do
    context 'when valid' do
      it 'authenticates' do
        token = access_token.generate_token
        expect(access_token.authenticate(token)).to be_truthy
      end
    end

    context 'when invalid' do
      it 'fails to authenticates' do
        access_token.generate_token
        expect(access_token.authenticate('fake')).to be_falsey
      end
    end
  end

  describe '#expired?' do
    context 'when expired' do
      it 'returns true' do
        access_token.update_column(:created_at, 15.days.ago)
        expect(access_token.expired?).to be_truthy
      end
    end

    context 'when not expired' do
      it 'return false' do
        access_token.update_column(:created_at, 10.days.ago)
        expect(access_token.expired?).to be_falsey
      end
    end
  end

  describe '#generate_token' do
    it 'generates an access token digest' do
      access_token.generate_token
      expect(access_token.token_digest).to_not be_nil
    end

    it 'returns an access token' do
      token = access_token.generate_token
      expect(token).to_not be_nil
    end
  end
end
