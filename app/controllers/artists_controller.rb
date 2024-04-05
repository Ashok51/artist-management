# frozen_string_literal: true

class ArtistsController < ApplicationController
  require 'csv'
  include ArtistMusicCreation
  include DatabaseExecution

  require_relative './concerns/sql_queries'

  def index
    @artists = []
    @page_number = params[:page].to_i || 1
    per_page = 5 # Set the number of records per page

    @total_pages = total_page_of_artist_table(per_page)

    query = SQLQueries::ORDER_ARTIST_RECORD

    result = Pagination.paginate(query, @page_number, per_page)

    @artists = Artist.build_artist_object_from_json(result)
  end

  def new
    @artist = Artist.new
    @artist.musics.build
  end

  def create
    ActiveRecord::Base.transaction do
      artist_id = create_artist_record

      create_music_of_artist(artist_id)
    end
    redirect_to artists_url, notice: 'Artist created successfully.'
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.error("Error while creating artist: #{e.message}")

    redirect_to artists_url, alert: 'Unable to create artist.'
  end

  def show
    artist_hash = show_artist

    @artist = Artist.new(artist_hash.first)
  end

  def edit
    show
  end

  def update
    ActiveRecord::Base.transaction do
      update_artist_and_music
    end
    redirect_to artists_url, notice: 'Artist updated successfully.'
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.error("Error updating artist: #{e.message}")

    redirect_to artists_url, alert: 'Unable to update artist.'
  end

  def destroy
    ActiveRecord::Base.transaction do
      delete_artist_and_associated_musics
    end
    redirect_to artists_url, notice: 'Artist deleted successfully.'
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.error("Error while deleting artist: #{e.message}")

    redirect_to artists_url, alert: 'Unable to delete artist.'
  end

  def import
    CsvImportService.import_artists_and_musics(params[:file])
    redirect_to root_url, notice: 'Artists and Musics imported successfully.'
  rescue StandardError => e
    Rails.logger.error("Error while importing artist: #{e.message}")

    redirect_to artists_url, alert: 'Unable to import artists.'
  end

  def export
    csv_data = CsvExportService.export_artists_and_musics

    send_data csv_data, filename: 'artists_with_musics.csv'
  rescue StandardError => e
    Rails.logger.error("Error while exporting artists: #{e.message}")

    redirect_to artists_url, alert: 'Unable to export the artists.'
  end

  private

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
