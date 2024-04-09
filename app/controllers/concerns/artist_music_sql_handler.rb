# frozen_string_literal: true

module ArtistMusicSqlHandler
  extend ActiveSupport::Concern

  def create_artist_record
    artist_sql = SQLQueries::CREATE_ARTIST

    query_with_field_values = query_and_field_values_array_of_artist(artist_sql, artist_params)
    result = sanitize_and_execute_sql(query_with_field_values)

    result.first['id']
  end

  def create_music_of_artist(artist_id)
    # create bulk music upload
    values = []
    musics_params.each do |music_params|
      param = music_params[1]
      values << [
        param[:title],
        param[:album_name],
        param[:genre],
        Time.current,
        Time.current,
        artist_id
      ]
    end

    create_bulk_music(values, artist_id)
  end

  def update_artist_and_music
    artist_id = params[:id]

    update_artist_sql = SQLQueries::UPDATE_ARTIST

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

    sanitize_and_execute_sql(query_with_field_values)

    update_music
  end

  def update_music
    artist_id = params[:id]
    update_array = []
    delete_music_ids = []
    create_array = []
    musics_params.each do |music_params|
      formatted_music_params = music_params[1]
      music_id = formatted_music_params['id']
      if formatted_music_params['_destroy'] == '1'
        delete_music_ids << music_id
      elsif music_id.nil?
        create_array << formatted_music_params
      else
        update_array << formatted_music_params
      end
    end
    update_array_of_musics(update_array, artist_id) if update_array.present?
    delete_array_of_musics(delete_music_ids) if delete_music_ids.present?
    create_new_music_during_update(artist_id, create_array) if create_array.present?
  end

  def create_new_music_during_update(artist_id, musics_params_array)
    # create bulk music upload
    values = []
    musics_params_array.each do |param|
      values << [
        param[:title],
        param[:album_name],
        param[:genre],
        Time.current,
        Time.current,
        artist_id
      ]
    end

    create_bulk_music(values, artist_id)
  end

  def create_bulk_music(values, _artist_id)
    placeholders = values.map { '(?,?,?,?,?,?)' }.join(',')
    flattened_values = values.flatten

    sanitized_sql = ActiveRecord::Base.send(:sanitize_sql_array, 
                                  [SQLQueries::CREATE_BULK_MUSIC.call(placeholders), *flattened_values])

    execute_sql(sanitized_sql)
  end

  def delete_array_of_musics(delete_music_ids)
    music_ids = delete_music_ids.join(',')
    sql_query = SQLQueries::BULK_MUSIC_DELETE.call(music_ids)

    execute_sql(sql_query)
  end

  def update_array_of_musics(update_array_of_params, _artist_id)
    updates = []
    update_array_of_params.each do |params|
      music_id = params['id']
      title = params['title']
      album_name = params['album_name']
      genre = params['genre']

      updates << "(#{music_id}, '#{title}', '#{album_name}', #{genre})"
    end

    updates_string = updates.join(', ')

    sql_query = <<-SQL
      UPDATE musics AS m
      SET title = u.title,
          album_name = u.album_name,
          genre = u.genre,
          updated_at = NOW()
      FROM (VALUES#{' '}
        #{updates_string}
      ) AS u(id, title, album_name, genre)
      WHERE m.id = u.id;
    SQL

    execute_sql(sql_query)
  end

  def delete_artist_and_associated_musics
    artist_id = params[:id]
    # delete_all_musics(artist_id)
    delete_artist(artist_id)
  end

  def show_artist
    artist_id = params[:id]

    artist_sql = SQLQueries::SELECT_ARTIST

    query_with_field_values = [artist_sql, artist_id]

    sanitize_and_execute_sql(query_with_field_values).to_a
  end

  def total_page_of_artist_table(per_page)
    query = SQLQueries::COUNT_ARTISTS

    total_count = execute_sql(query).first['total_count'].to_i

    (total_count.to_f / per_page).ceil
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

  def query_and_field_values_array_of_music(sql_music, music_params, artist_id)
    [
      sql_music,
      music_params[:title],
      music_params[:album_name],
      music_params[:genre],
      Time.current,
      Time.current,
      artist_id
    ]
  end

  def create_music(artist_id, music_params)
    music_sql = SQLQueries::CREATE_MUSIC

    query_with_field_values = query_and_field_values_array_of_music(music_sql, music_params, artist_id)
    sanitize_and_execute_sql(query_with_field_values)
  end

  def update_existing_music(artist_id, music_id, music_params)
    music_sql = SQLQueries::UPDATE_MUSIC

    query_with_field_values = [
      music_sql,
      music_params['title'],
      music_params['album_name'],
      music_params['genre'],
      music_id,
      artist_id
    ]

    sanitize_and_execute_sql(query_with_field_values)
  end

  def delete_music(artist_id, music_id)
    sql_delete = SQLQueries::DELETE_MUSIC

    query_with_field_values = [sql_delete, music_id, artist_id]
    sanitize_and_execute_sql(query_with_field_values)
  end

  def delete_artist(artist_id)
    sql_to_delete_artist = SQLQueries::DELETE_SPECIFIC_ARTIST.call(artist_id)

    execute_sql(sql_to_delete_artist)
  end

  def sanitize_and_execute_sql(field_values_with_query)
    sanitized_sql = ActiveRecord::Base.send(:sanitize_sql_array, field_values_with_query)
    execute_sql(sanitized_sql)
  end
end
