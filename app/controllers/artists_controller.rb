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
    artist_hash = show_artist(params[:id])

    @artist = Artist.new(artist_hash.first)
  end

  def edit
    show
  end

  def update
    binding.pry
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
    artist_params.require(:musics_attributes)
  end
end
