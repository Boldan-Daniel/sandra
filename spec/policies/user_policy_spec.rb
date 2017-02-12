require 'rails_helper'

describe UserPolicy do
  subject { described_class }
  let(:daniel) { build(:user) }

  permissions :create? do
    it 'grants access' do
      expect(subject).to permit(nil, User.new)
    end
  end

  permissions :index? do
    it 'denies access if user is not admin' do
      expect(subject).not_to permit(build(:user), User.new)
    end

    it 'grants access if user is admin' do
      expect(subject).to permit(build(:admin), User.new)
    end
  end

  permissions :show?, :update?, :destroy? do
    it 'denies access to users that are not owner or admin' do
      expect(subject).not_to permit(build(:user), daniel)
    end

    it 'grants access if user is owner' do
      expect(subject).to permit(daniel, daniel)
    end

    it 'grants access if user is admin' do
      expect(subject).to permit(build(:admin), daniel)
    end
  end
end