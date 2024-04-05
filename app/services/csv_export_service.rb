# frozen_string_literal: true

class CsvExportService
  extend DatabaseExecution

  def self.export_artists_and_musics
    artists_with_musics = []

    artists_with_musics_data = fetch_artists_with_music # Add self here

    # Convert result set to array of hashes
    artists_with_musics_data.each do |row|
      artist = {
        'id' => row['id'],
        'name' => row['name'],
        'date_of_birth' => row['date_of_birth'],
        'address' => row['address'],
        'first_release_year' => row['first_release_year'],
        'gender' => row['gender'],
        'no_of_albums_released' => row['no_of_albums_released'],
        'music_title' => row['music_title'],
        'music_album_name' => row['music_album_name'],
        'music_genre' => row['music_genre']
      }
      artists_with_musics << artist
    end

    CSV.generate(headers: true) do |csv|
      csv << ['ID', 'Name', 'Date of Birth', 'Address', 'First Release Year', 'Gender', 'No. of Albums Released',
              'Music Title', 'Music Album Name', 'Music Genre']
      artists_with_musics.each do |artist|
        csv << [artist['id'], artist['name'], artist['date_of_birth'], artist['address'], artist['first_release_year'],
                artist['gender'], artist['no_of_albums_released'], artist['music_title'], artist['music_album_name'], artist['music_genre']]
      end
    end
  end

  def self.fetch_artists_with_music
    artists_query = SQLQueries::FETCH_ARTISTS_WITH_MUSIC

    execute_sql(artists_query)
  end
end
