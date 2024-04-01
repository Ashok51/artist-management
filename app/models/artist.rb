class Artist < ApplicationRecord
  has_many :musics
  
  enum gender: { male: 'male',
                 female: 'female',
                 other: 'other' }

  validates :name, :date_of_birth, :address, :first_release_year, presence: true

  accepts_nested_attributes_for :musics, allow_destroy: true
end
