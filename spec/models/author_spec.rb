require 'rails_helper'

RSpec.describe Author, type: :model do
  it 'has a valid factory' do
    expect(build(:author)).to be_valid
  end

  it { should validate_presence_of(:given_name) }
  it { should validate_presence_of(:family_name) }

  # associations specs
  it { should have_many(:books) }

end
