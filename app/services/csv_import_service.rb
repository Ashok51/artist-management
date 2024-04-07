# frozen_string_literal: true

class CsvImportService
  extend DatabaseExecution

  def self.import_artists_and_musics(file)
    CSV.foreach(file.path, headers: true) do |row|
      artist_attrs = row.to_h.slice('name', 'date_of_birth', 'address', 'first_release_year', 'gender')
      artist_attrs['gender'] = Artist.map_gender_string_to_enum(artist_attrs) # Map string to enum value

      artist_values = artist_attrs.values.map { |value| sanitize_and_quote(value) }.join(', ')

      result = create_artist_from_csv(artist_values)

      artist_id = result[0]['id']

      music_attrs = row.to_h.slice('title', 'album_name', 'genre')
      music_attrs['genre'] = Music.map_genre_string_to_enum(music_attrs) # Map string to enum value

      music_values = music_attrs.values.map { |value| sanitize_and_quote(value) }.join(', ')

      create_music_from_csv(music_values, artist_id)
    end
  end

  def self.create_artist_from_csv(artist_values)
    artist_sql = SQLQueries::CREATE_ARTIST_FROM_CSV.call(artist_values)
    execute_sql(artist_sql)
  end

  def self.create_music_from_csv(music_values, artist_id)
    music_sql = SQLQueries::CREATE_MUSIC_FROM_CSV.call(music_values, artist_id)
    execute_sql(music_sql)
  end

  def self.sanitize_and_quote(value)
    ActiveRecord::Base.connection.quote(value)
  end
end
