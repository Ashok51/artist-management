class Artist < ApplicationRecord
  has_many :musics, dependent: :destroy, inverse_of: :artist
  
  enum gender: { male: 1,
                 female: 2,
                 other: 3 }

  validates :date_of_birth, :address, :first_release_year, presence: true

  validates :name, uniqueness: true

  accepts_nested_attributes_for :musics, allow_destroy: true

  def self.build_artist_object_from_json(result)
    artists = []
    result.each do |artist|
      artists << Artist.new(artist)
    end

    artists
  end

  def self.map_gender_string_to_enum(music_attrs)
    genders[music_attrs["gender"]]
  end
end
