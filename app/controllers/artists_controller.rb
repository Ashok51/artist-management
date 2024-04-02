class ArtistsController < ApplicationController
  require 'csv'

  def index
    @artists = Artist.all
  end

  def import
    begin
      CsvImportService.import_artists_and_musics(params[:file])
      redirect_to root_url, notice: "Artists and Musics imported successfully."
    rescue StandardError => e
      flash[:alert] = "An error occurred during import: #{e.message}"
      redirect_to root_url
    end
  end

  def export
    @artists = Artist.includes(:musics)

    respond_to do |format|
      format.csv do
        send_data generate_csv_data(@artists), filename: "artists_with_musics.csv"
      end
    end
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

  def show
    @artist = Artist.find(params[:id])
  end

  def edit
    @artist = Artist.find(params[:id])
  end

  def update
    @artist = Artist.find(params[:id])
    if @artist.update!(artist_params)
      flash[:notice] = "Artist updated successfully."
      redirect_to @artist
    else
      render :edit
    end
  end

  def destroy
    @artist = Artist.find(params[:id])
    @artist.destroy
    redirect_to artists_url, notice: 'Artist was successfully deleted.'
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

  def generate_csv_data(artists)
    CSV.generate(headers: true) do |csv|
      csv << ['Name', 'Date of Birth', 'Address', 'First Release Year', 'Gender', 'No. of Albums Released', 'Music Title', 'Album Name', 'Genre']
      
      artists.each do |artist|
        if artist.musics.any?
          artist.musics.each do |music|
            csv << [artist.name, artist.date_of_birth, artist.address, artist.first_release_year, artist.gender, artist.no_of_albums_released, music.title, music.album_name, music.genre]
          end
        else
          csv << [artist.name, artist.date_of_birth, artist.address, artist.first_release_year, artist.gender, artist.no_of_albums_released]
        end
      end
    end
  end
end
