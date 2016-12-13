require 'rails_helper'

RSpec.describe Publisher, type: :model do
  it 'has a valid factory' do
    expect(build :publisher).to be_valid
  end

  it { should validate_presence_of(:name) }

  # association specs
  it { should have_many(:books) }
end
