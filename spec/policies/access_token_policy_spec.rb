require 'rails_helper'

describe AccessTokenPolicy do
  subject { described_class }
  let(:user) { create(:user) }

  permissions :create? do
    it 'grants access' do
      expect(subject).to permit(nil, AccessToken.new)
    end
  end

  permissions :destroy? do
    it 'denies access users that are not owner' do
      expect(subject).not_to permit(build(:admin), AccessToken.new)
    end

    it 'grants access if user is owner' do
      expect(subject).to permit(user, AccessToken.new(user: user))
    end
  end
end