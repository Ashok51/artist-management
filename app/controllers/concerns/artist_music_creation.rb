# frozen_string_literal: true

module ArtistMusicCreation
  extend ActiveSupport::Concern

  def create_artist_record
    artist_sql = SQLQueries::CREATE_ARTIST

    query_with_field_values = query_and_field_values_array_of_artist(artist_sql, artist_params)
    result = sanitize_and_execute_sql(query_with_field_values)

    result.first['id']
  end

  def create_music_of_artist(artist_id)
    musics_params.each do |music_params|
      music_sql = SQLQueries::CREATE_MUSIC

      query_with_field_values = query_and_field_values_array_of_music(music_sql, music_params[1], artist_id)
      sanitize_and_execute_sql(query_with_field_values)
    end
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

    musics_params.each_value do |music_params|
      music_id = music_params['id']
      if music_params['_destroy'] == '1'
        delete_music(artist_id, music_id)
      elsif music_id.nil?
        create_music(artist_id, music_params)
      else
        update_existing_music(artist_id, music_id, music_params)
      end
    end
  end

  def delete_artist_and_associated_musics
    artist_id = params[:id]
    delete_all_musics(artist_id)
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

  def delete_all_musics(artist_id)
    sql_to_delete_musics = SQLQueries::DELETE_ARTIST_MUSICS.call(artist_id)

    execute_sql(sql_to_delete_musics)
  end

  def delete_artist(artist_id)
    sql_to_delete_artist = SQLQueries::DELETE_SPECIFIC_ARTIST.call(artist_id)
    
    execute_sql(sql_to_delete_artist)
  end

  def execute_sql(sql)
    ActiveRecord::Base.connection.execute(sql)
  end

  def sanitize_and_execute_sql(field_values_with_query)
    sanitized_sql = ActiveRecord::Base.send(:sanitize_sql_array, field_values_with_query)
    execute_sql(sanitized_sql)
  end
end
