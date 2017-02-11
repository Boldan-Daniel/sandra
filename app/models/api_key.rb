class ApiKey < ApplicationRecord
  has_many :access_tokens
  
  before_validation :generate_key, on: :create

  validates :key, presence: true
  validates :active, :inclusion => {:in => [true, false]}

  scope :activated, -> { where(active: true) }

  def disable
    update_column :active, false
  end

  def generate_key
    self.key = SecureRandom.hex
  end
end
