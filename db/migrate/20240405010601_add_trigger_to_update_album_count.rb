class AddTriggerToUpdateAlbumCount < ActiveRecord::Migration[7.1]
  def up
    # Trigger for inserting a new music record
    execute <<-SQL
      CREATE OR REPLACE FUNCTION update_album_count_after_insert()
      RETURNS TRIGGER AS $$
      BEGIN
          UPDATE artists
          SET no_of_albums_released = (
              SELECT COUNT(DISTINCT album_name)
              FROM musics
              WHERE artist_id = NEW.artist_id
          )
          WHERE id = NEW.artist_id;

          RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER after_music_insert
      AFTER INSERT ON musics
      FOR EACH ROW
      EXECUTE FUNCTION update_album_count_after_insert();
    SQL

    # Trigger for updating an existing music record
    execute <<-SQL
      CREATE OR REPLACE FUNCTION update_album_count_after_update()
      RETURNS TRIGGER AS $$
      BEGIN
          UPDATE artists
          SET no_of_albums_released = (
              SELECT COUNT(DISTINCT album_name)
              FROM musics
              WHERE artist_id = NEW.artist_id
          )
          WHERE id = NEW.artist_id;

          RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER after_music_update
      AFTER UPDATE ON musics
      FOR EACH ROW
      EXECUTE FUNCTION update_album_count_after_update();
    SQL

    # Trigger for deleting a music record
    execute <<-SQL
      CREATE OR REPLACE FUNCTION update_album_count_after_delete()
      RETURNS TRIGGER AS $$
      BEGIN
          UPDATE artists
          SET no_of_albums_released = (
              SELECT COUNT(DISTINCT album_name)
              FROM musics
              WHERE artist_id = OLD.artist_id
          )
          WHERE id = OLD.artist_id;

          RETURN OLD;
      END;
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER after_music_delete
      AFTER DELETE ON musics
      FOR EACH ROW
      EXECUTE FUNCTION update_album_count_after_delete();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER after_music_insert ON musics;
      DROP FUNCTION update_album_count_after_insert();

      DROP TRIGGER after_music_update ON musics;
      DROP FUNCTION update_album_count_after_update();

      DROP TRIGGER after_music_delete ON musics;
      DROP FUNCTION update_album_count_after_delete();
    SQL
  end
end

