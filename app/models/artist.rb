class Artist < ApplicationRecord
  enum gender: { male: 'male', female: 'female', other: 'other' }

  validates :name, :date_of_birth, :gender, :address, :first_released_year, presence: true
end
