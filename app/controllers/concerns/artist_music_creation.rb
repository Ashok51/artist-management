# frozen_string_literal: true

module ArtistMusicCreation
  extend ActiveSupport::Concern

  def create_artist_record
    artist_sql = <<-SQL
                      INSERT INTO artists
                      (name, date_of_birth, gender, address, first_release_year, created_at, updated_at)
                      VALUES (?, ?, ?, ?, ?, ?, ?)
                      RETURNING id
    SQL

    query_with_field_values = query_and_field_values_array_of_artist(artist_sql, artist_params)

    # sanitizing set up values dynamically and prevents sql injections, then execute artist creation
    result = sanitize_and_execure_sql(query_with_field_values)

    result.first['id']
  end

  def create_music_of_artist(artist_id)
    music_sql = <<-SQL
                     INSERT INTO musics
                     (title, album_name, genre, created_at, updated_at, artist_id)
                     VALUES (?, ?, ?, ?, ?, ?)
    SQL

    musics_params.each do |music_params|
      sanitized_music_params = music_params[1]
      query_with_field_values = query_and_field_values_array_of_music(music_sql, sanitized_music_params, artist_id)

      sanitize_and_execure_sql(query_with_field_values)
    end
  end

  def show_artist
    artist_id = params[:id]

    artist_sql = <<-SQL
                      SELECT *
                      FROM artists
                      WHERE id = ?
    SQL

    query_with_field_values = [artist_sql, artist_id]

    sanitize_and_execure_sql(query_with_field_values).to_a
  end

  def update_artist_and_music
    artist_id = params[:id]

    update_artist_sql = <<-SQL
      UPDATE artists
      SET name = ?, date_of_birth = ?, gender = ?, address = ?, first_release_year = ?, updated_at = ?
      WHERE id = ?
    SQL

    #for sanitize values and then execute
    query_with_field_values = [
      update_artist_sql,
      artist_params[:name],
      artist_params[:date_of_birth],
      artist_params[:gender],
      artist_params[:address],
      artist_params[:first_release_year],
      Time.current,
      artist_id
    ]

    sanitize_and_execure_sql(query_with_field_values)

    update_music
  end

  def update_music
    artist_id = params[:id]

    sql_updates = []
    sql_deletes = []

    # Iterate over the musics_attributes and build SQL statements for updates
    musics_params.each_value do |music_params|
      music_id = music_params['id']
      if music_params['_destroy'] == '1'  #removed music item during update
        sql_delete = <<-SQL
          DELETE FROM musics
          WHERE id = #{music_id} AND artist_id = #{artist_id}
        SQL

        # Add the SQL delete statement to the array
        sql_deletes << sql_delete

        next
      end

      if music_id.nil? # freshly created music
        sql_music = <<-SQL
          INSERT INTO musics
          (title, album_name, genre, created_at, updated_at, artist_id)
          VALUES (?, ?, ?, ?, ?, ?)
        SQL

        query_with_field_values = query_and_field_values_array_of_music(sql_music, music_params, artist_id)

        sanitize_and_execure_sql(query_with_field_values)

        next
      end

      # any music item's value update
      sql_update = <<-SQL
        UPDATE musics
        SET
          title = '#{music_params['title']}',
          album_name = '#{music_params['album_name']}',
          genre = #{music_params['genre']}
        WHERE id = #{music_id} AND artist_id = #{artist_id}
      SQL

      sql_updates << sql_update
    end

    # Execute the SQL update statements
    execute_sql_for_array_of_sqls(sql_updates)

    # Execute the SQL delete statements
    execute_sql_for_array_of_sqls(sql_deletes)
  end

  def delete_artist_and_associated_musics
    artist_id = params[:id]
    sql_to_delete_musics = "DELETE FROM musics WHERE artist_id = #{artist_id}"
    sql_to_delete_artist = "DELETE FROM artists WHERE id = #{artist_id}"
    execute_sql(sql_to_delete_musics)
    execute_sql(sql_to_delete_artist)
  end

  private

  def query_and_field_values_array_of_artist(query, artist_params)
    [
      query,
      artist_params[:name],
      artist_params[:date_of_birth],
      artist_params[:gender],
      artist_params[:address],
      artist_params[:first_release_year],
      Time.current,
      Time.current
    ]
  end

  def query_and_field_values_array_of_music(sql_music, music_params, artist_id = nil)
    query_with_field_values = [
      sql_music,
      music_params[:title],
      music_params[:album_name],
      music_params[:genre],
      Time.current,
      Time.current
    ]

    query_with_field_values << artist_id if artist_id.present?

    query_with_field_values
  end

  def execute_sql_for_array_of_sqls(sql_list)
    sql_list.each do |sql|
      execute_sql(sql)
    end
  end

  def execute_sql(sql)
    ActiveRecord::Base.connection.execute(sql)
  end

  def sanitize_and_execure_sql(field_values_with_query)
    sanitized_sql = ActiveRecord::Base.send(:sanitize_sql_array, field_values_with_query)

    ActiveRecord::Base.connection.execute(sanitized_sql)
  end
end
