# frozen_string_literal: true

class CsvExportService
  extend DatabaseExecution

  def self.export_artists_and_musics
    artists_with_musics = []

    artists_with_musics_data = fetch_artists_with_music

    artists_with_musics_data.each do |row|
      artist = {
        'id' => row['id'],
        'name' => row['name'],
        'date_of_birth' => row['date_of_birth'],
        'address' => row['address'],
        'first_release_year' => row['first_release_year'],
        'gender' => map_gender_to_string(row['gender']), # Map gender to string
        'no_of_albums_released' => row['no_of_albums_released'],
        'music_title' => row['music_title'],
        'music_album_name' => row['music_album_name'],
        'music_genre' => map_genre_to_string(row['music_genre']) # Map genre to string
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

  def self.map_gender_to_string(gender_enum)
    case gender_enum
    when 1
      'male'
    when 2
      'female'
    when 3
      'other'
    else
      'unknown'
    end
  end

  def self.map_genre_to_string(genre_enum)
    case genre_enum
    when 0
      'rock'
    when 1
      'pop'
    when 2
      'hip_hop'
    when 3
      'jazz'
    else
      'unknown'
    end
  end
end
