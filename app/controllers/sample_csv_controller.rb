class SampleCsvController < ApplicationController
  def download
    send_file(
      Rails.root.join('public', 'sample_csv', 'artist_music.csv'),
      filename: "artist_music.csv",
      type: "text/csv"
    )
  end
end
