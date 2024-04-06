# frozen_string_literal: true

module SQLQueries
  CREATE_ARTIST = <<-SQL
    INSERT INTO artists
    (name, date_of_birth, gender, address, first_release_year, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?, ?, ?)
    RETURNING id
  SQL

  CREATE_MUSIC = <<-SQL
    INSERT INTO musics
    (title, album_name, genre, created_at, updated_at, artist_id)
    VALUES (?, ?, ?, ?, ?, ?)
  SQL

  UPDATE_ARTIST = <<-SQL
    UPDATE artists
    SET name = ?, date_of_birth = ?, gender = ?, address = ?, first_release_year = ?, updated_at = ?
    WHERE id = ?
  SQL

  UPDATE_MUSIC = <<-SQL
    UPDATE musics
    SET
      title = ?,
      album_name = ?,
      genre = ?
    WHERE id = ? AND artist_id = ?
  SQL

  DELETE_MUSIC = <<-SQL
    DELETE FROM musics
    WHERE id = ? AND artist_id = ?
  SQL

  DELETE_ALL_MUSICS = <<-SQL
    DELETE FROM musics WHERE artist_id = ?
  SQL

  DELETE_ARTIST = <<-SQL
    DELETE FROM artists WHERE id = ?
  SQL

  COUNT_ARTISTS = <<-SQL
    SELECT COUNT(*) AS total_count FROM artists
  SQL

  SELECT_ARTIST = <<-SQL
    SELECT * FROM artists WHERE id = ?
  SQL

  ORDER_ARTIST_RECORD = <<-SQL
    SELECT * FROM artists
    ORDER BY id
  SQL

  CREATE_ARTIST_FROM_CSV = lambda do |artist_values|
    "INSERT INTO artists (name, date_of_birth, address, first_release_year, gender, no_of_albums_released, created_at, updated_at)
    VALUES (#{artist_values}, NOW(), NOW())
    ON CONFLICT (name) DO UPDATE SET
      date_of_birth = EXCLUDED.date_of_birth,
      address = EXCLUDED.address,
      first_release_year = EXCLUDED.first_release_year,
      gender = EXCLUDED.gender,
      no_of_albums_released = EXCLUDED.no_of_albums_released,
      updated_at = NOW()
    RETURNING id"
  end

  CREATE_MUSIC_FROM_CSV = lambda do |music_values, artist_id|
     "INSERT INTO musics (title, album_name, genre, artist_id, created_at, updated_at)
      VALUES (#{music_values}, #{artist_id}, NOW(), NOW())"
  end

  DELETE_ARTIST_MUSICS = lambda do |artist_id|
    "DELETE FROM musics WHERE artist_id = #{artist_id}"
  end

  DELETE_SPECIFIC_ARTIST = lambda do |artist_id|
    "DELETE FROM artists WHERE id = #{artist_id}"
  end

  FETCH_ARTISTS_WITH_MUSIC = <<-SQL
    SELECT artists.*, musics.title AS music_title, musics.album_name AS music_album_name, musics.genre AS music_genre
    FROM artists
    LEFT JOIN musics ON artists.id = musics.artist_id
  SQL

  LIST_ALL_USERS = <<-SQL
    SELECT * FROM users
  SQL

  COUNT_USERS = <<-SQL
    SELECT COUNT(*) AS total_count FROM users
  SQL

  ORDERD_USERS_RECORD = <<-SQL
    SELECT * FROM users
    ORDER BY id
  SQL
end
