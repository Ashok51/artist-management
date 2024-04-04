# frozen_string_literal: true

class ArtistsController < ApplicationController
  include ArtistMusicCreation

  def index
    @artists = []
    result = ActiveRecord::Base.connection.execute('SELECT * FROM artists')
    result.each do |artist|
      @artists << Artist.new(artist)
    end
  end

  def new
    @artist = Artist.new
    @artist.musics.build
  end

  def create
    artist_id = create_artist_record

    create_music_of_artist(artist_id)

    redirect_to artists_url, notice: 'Artist created successfully.'
  end

  def show
    artist_hash = show_artist

    @artist = Artist.new(artist_hash.first)
  end

  def edit
    show
  end

  def update
    update_artist_and_music

    redirect_to artists_url, notice: 'Artist updated successfully.'
  end

  def destroy
    ActiveRecord::Base.transaction do
      delete_artist_and_associated_musics
    rescue ActiveRecord::StatementInvalid => e
      puts "Unable to delete due to: #{e.message}"
    end

    redirect_to artists_url, notice: 'Artist deleted successfully.'
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
