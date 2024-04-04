# frozen_string_literal: true

class CsvImportService
  def self.import_artists_and_musics(file)
    CSV.foreach(file.path, headers: true) do |row|
      artist_attrs = row.to_h.slice('name', 'date_of_birth', 'address', 'first_release_year', 'gender',
                                    'no_of_albums_released')
      artist_values = artist_attrs.values.map { |value| sanitize_and_quote(value) }.join(', ')

      result = create_artist_from_csv(artist_values)

      artist_id = result[0]['id']

      music_attrs = row.to_h.slice('title', 'album_name', 'genre')
      music_values = music_attrs.values.map { |value| sanitize_and_quote(value) }.join(', ')

      create_music_from_csv(music_values, artist_id)
    end
  end

  def self.create_artist_from_csv(artist_values)
    artist_sql = "INSERT INTO artists (name, date_of_birth, address, first_release_year, gender, no_of_albums_released, created_at, updated_at)
    VALUES (#{artist_values}, NOW(), NOW())
    ON CONFLICT (name) DO UPDATE SET
      date_of_birth = EXCLUDED.date_of_birth,
      address = EXCLUDED.address,
      first_release_year = EXCLUDED.first_release_year,
      gender = EXCLUDED.gender,
      no_of_albums_released = EXCLUDED.no_of_albums_released,
      updated_at = NOW()
    RETURNING id"

    execute_sql(artist_sql)
  end

  def self.create_music_from_csv(music_values, artist_id)
    music_sql = "INSERT INTO musics (title, album_name, genre, artist_id, created_at, updated_at)
    VALUES (#{music_values}, #{artist_id}, NOW(), NOW())"

    execute_sql(music_sql)
  end

  def self.execute_sql(sql)
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.sanitize_and_quote(value)
    ActiveRecord::Base.connection.quote(value)
  end
end
