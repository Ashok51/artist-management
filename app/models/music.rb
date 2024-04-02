class Music < ApplicationRecord
  belongs_to :artist

  validates :title, :album_name, :genre, presence: true

  enum genre: { rock: 0,
                pop: 1,
                hip_hop: 2,
                jazz: 3 }
end
