# frozen_string_literal: true

module ArtistsHelper
  def gender_options_for_select
    Artist.genders.map { |key, value| [key, value] }
  end

  def genre_options_for_select
    Music.genres.map { |key, value| [key, value] }
  end

  def selected_artist_gender(gender)
    Artist.genders[gender]
  end

  def selected_music_genre(genre)
    Music.genres[genre]
  end
end
