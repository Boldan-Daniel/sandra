require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  it 'has a valid factory' do
    expect(build(:user)).to be_valid
  end

  describe '.email validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).ignoring_case_sensitivity }
  end

  it { should validate_presence_of(:password) }

  it 'generates a confirmation token' do
    user.valid?
    expect(user.confirmation_token).to_not be_nil
  end

  it 'downcases email before validating' do
    user.email = 'Daniel@sandra.app'
    expect(user.valid?).to be_truthy
    expect(user.email).to eq 'daniel@sandra.app'
  end
end
