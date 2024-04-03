class Music < ApplicationRecord
  belongs_to :artist, inverse_of: :musics

  validates :title, :album_name, :genre, presence: true

  enum genre: { rock: 0,
                pop: 1,
                hip_hop: 2,
                jazz: 3 }

  after_commit :update_artist_album_count

  private

  def update_artist_album_count
    #not using direct association, coz frozon error after delete action
    Artist.find(artist_id).update_albums_released(album_released_count)
  end

  def album_released_count
    Music.where(artist_id: artist_id)
         .group(:album_name)
         .distinct
         .count
         .values
         .count
  end
end
