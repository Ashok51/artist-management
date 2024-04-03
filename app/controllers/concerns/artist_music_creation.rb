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

    # we are puting => [query, field_value_1, field_value_2, ....]
    query_with_field_values = [artist_sql,
                         artist_params[:name],
                         artist_params[:date_of_birth],
                         artist_params[:gender],
                         artist_params[:address],
                         artist_params[:first_release_year],
                         Time.current,
                         Time.current]

    # sanitizing set up values dynamically and prevents sql injections, then execute artist creation
    result = sanitize_and_execure_sql(query_with_field_values)

    result.first['id']
  end

  def create_music_of_artist(artist_id)
    music_sql = <<-SQL
                     INSERT INTO musics
                     (artist_id, title, album_name, genre, created_at, updated_at)
                     VALUES (?, ?, ?, ?, ?, ?)
                   SQL

    musics_params.each do |music_params|
      sanitized_music_params = music_params[1]
      query_with_field_values = [music_sql,
                           artist_id,
                           sanitized_music_params[:title],
                           sanitized_music_params[:album_name],
                           sanitized_music_params[:genre],
                           Time.current,
                           Time.current]

      sanitize_and_execure_sql(query_with_field_values)
    end
  end

  def show_artist(artist_id)
    artist_sql = <<-SQL
                      SELECT *
                      FROM artists
                      WHERE id = ?
                    SQL

    query_with_field_values = [artist_sql, artist_id]

    sanitize_and_execure_sql(query_with_field_values).to_a
  end

  private

  def sanitize_and_execure_sql(field_values_with_query)
    sanitized_sql = ActiveRecord::Base.send(:sanitize_sql_array, field_values_with_query)

    ActiveRecord::Base.connection.execute(sanitized_sql)
  end
end
