class ArtistsController < ApplicationController
  def index
    @artists = Artist.all
  end

  def new
    @artist = Artist.new
    @artist.musics.build
  end

  def create
    @artist = Artist.new(artist_params)
    if @artist.save!
      flash[:notice] = "Artist Created Successfully."
      redirect_to @artist
    else
      render :new
    end
  end

  def edit
    @artist = Artist.find(params[:id])
  end

  def update
    @artist = Artist.find(params[:id])
    if @artist.update(artist_params)
      flash[:notice] = "Artist updated successfully."
      redirect_to @artist
    else
      render :edit
    end
  end

  def show
    @artist = Artist.find(params[:id])
  end

  private

  def artist_params
    params.require(:artist).permit(:name, :date_of_birth,
                                    :gender, :address, :first_release_year,
                                    :no_of_albums_released,
                                    musics_attributes: %i[
                                      id title album_name genre _destroy
                                    ])
  end
end
