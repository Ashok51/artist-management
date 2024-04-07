class Music < ApplicationRecord
  belongs_to :artist, inverse_of: :musics

  validates :title, :album_name, :genre, presence: true

  enum genre: { rock: 0,
                pop: 1,
                hip_hop: 2,
                jazz: 3 }

  def self.map_genre_string_to_enum(artist_attrs)
    genres[artist_attrs['genre']]
  end
end
