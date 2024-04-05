class User < ApplicationRecord
  validates :first_name, :last_name, :phone, :date_of_birth, :gender, :address, presence: true

  # Enum gender
  enum gender: { male: 1, female: 2, other: 3 }
end
