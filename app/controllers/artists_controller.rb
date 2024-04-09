# frozen_string_literal: true

class ArtistsController < ApplicationController
  before_action :set_artist, only: %i[show edit update destroy]
  before_action :set_page_number, only: [:index]

  require 'csv'
  include ArtistMusicSqlHandler
  include DatabaseExecution

  require_relative './concerns/sql_queries'

  def index
    per_page = 5
    @total_pages = total_page_of_artist_table(per_page)
    @artists = paginate_artists(per_page)
  end

  def new
    @artist = Artist.new
    @artist.musics.build
  end

  def create
    ActiveRecord::Base.transaction do
      artist_id = create_artist_record
      create_music_of_artist(artist_id) if musics_params.present?
    end
    redirect_to artists_url, notice: 'Artist created successfully.'
  rescue ActiveRecord::StatementInvalid => e
    handle_error(e, 'Unable to create artist.')
  end

  def show; end

  def edit; end

  def update
    ActiveRecord::Base.transaction do
      update_artist_and_music
    end
    redirect_to artists_url, notice: 'Artist updated successfully.'
  rescue ActiveRecord::StatementInvalid => e
    handle_error(e, 'Unable to update artist.')
  end

  def destroy
    ActiveRecord::Base.transaction do
      delete_artist_and_associated_musics
    end
    redirect_to artists_url, notice: 'Artist deleted successfully.'
  rescue ActiveRecord::StatementInvalid => e
    handle_error(e, 'Unable to delete artist.')
  end

  def import
    CsvImportService.import_artists_and_musics(params[:file])
    redirect_to artists_url, notice: 'Artists and Musics imported successfully.'
  rescue StandardError => e
    handle_error(e, 'Unable to import artists.')
  end

  def export
    csv_data = CsvExportService.export_artists_and_musics
    send_data csv_data, filename: 'artists_with_musics.csv'
  rescue StandardError => e
    handle_error(e, 'Unable to export the artists.')
  end

  private

  def set_artist
    @artist = Artist.find(params[:id])
  end

  def set_page_number
    @page_number = params[:page].to_i || 1
  end

  def handle_error(exception, message)
    Rails.logger.error("Error: #{exception.message}")
    redirect_to artists_url, alert: message
  end

  def paginate_artists(per_page)
    query = SQLQueries::ORDER_ARTIST_RECORD
    result = Pagination.paginate(query, @page_number, per_page)
    Artist.build_artist_object_from_json(result)
  end

  def artist_params
    params.require(:artist).permit(:name, :date_of_birth,
                                   :gender, :address, :first_release_year,
                                   musics_attributes: %i[
                                     id title album_name genre _destroy
                                   ])
  end

  def musics_params
    artist_params[:musics_attributes].nil? ? [] : artist_params[:musics_attributes]
  end
end
