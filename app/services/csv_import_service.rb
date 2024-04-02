# frozen_string_literal: true

require 'csv'

class CsvImportService
  def self.import_artists_and_musics(file)
    CSV.foreach(file.path, headers: true) do |row|
      artist_attrs = row.to_h.slice('name', 'date_of_birth', 'address', 'first_release_year', 'gender',
                                    'no_of_albums_released')
      artist = Artist.find_or_initialize_by(name: artist_attrs['name'])
      artist.update(artist_attrs)

      music_attrs = row.to_h.slice('title', 'album_name', 'genre')
      artist.musics.create!(music_attrs)
    end
  end
end
