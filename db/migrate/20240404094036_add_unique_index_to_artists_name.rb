class AddUniqueIndexToArtistsName < ActiveRecord::Migration[6.0]
  def change
    add_index :artists, :name, unique: true
  end
end
