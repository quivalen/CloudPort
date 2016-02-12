class AddConnected < ActiveRecord::Migration
  def up
    execute "ALTER TABLE `connections` ADD COLUMN `is_connected` TINYINT(1) NOT NULL DEFAULT 0 AFTER `remote`"
    execute "CREATE INDEX `index_connections_on_is_connected` ON `connections` (`is_connected`)"
  end

  def down
    execute "ALTER TABLE `connections` DROP COLUMN `is_connected`"
  end
end
