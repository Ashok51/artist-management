class Artist < ApplicationRecord
  has_many :musics, dependent: :destroy, inverse_of: :artist
  
  enum gender: { male: 1,
                 female: 2,
                 other: 3 }

  validates :date_of_birth, :address, :first_release_year, presence: true

  validates :name, uniqueness: true

  accepts_nested_attributes_for :musics, allow_destroy: true

  def update_albums_released(album_released_count)
    update!(no_of_albums_released: album_released_count)
  end
end
